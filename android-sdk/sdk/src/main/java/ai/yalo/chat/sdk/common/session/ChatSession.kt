// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.common.session

import ai.yalo.chat.sdk.SessionMode
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.common.hash.xxhash32
import java.util.Locale
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

/**
 * Which conversation a chat is on.
 *
 * [id] scopes everything kept on the device, and [authUserId] is who the
 * backend is told it is talking to. The two carry the same suffix, which is
 * what keeps one conversation on the device pointing at one conversation on
 * the backend. A null [authUserId] asks the backend for a fresh anonymous
 * person.
 */
internal data class ChatSession(val id: String, val authUserId: String?)

/**
 * The session [config] is on, in the mode it asks for.
 *
 * [ephemeralId] is what makes one ephemeral chat a different conversation
 * from the next, as minted by [newEphemeralStamp]. It is ignored in the other
 * modes.
 *
 * Built the same way as `computeSessionId` and `computeEffectiveAuthUserId` in
 * the web SDK, so both clients agree on what one session is. The one place
 * they part is a config asking for [SessionMode.PerContext] with nothing in
 * `openContext`: there is no context to scope by, so the session is the base,
 * which is what the web SDK does when no context was given at all.
 */
internal fun sessionOf(config: YaloChatClientConfig, ephemeralId: String? = null): ChatSession {
    val suffix: String? = when (config.sessionMode) {
        SessionMode.Shared -> null
        SessionMode.PerContext -> config.openContext
            .takeIf { context -> context.isNotEmpty() }
            ?.let { context -> xxhash32(jsonOf(context)) }
        SessionMode.Ephemeral -> ephemeralId
    }
    val base: String = config.baseSessionId
    return ChatSession(
        id = if (suffix == null) base else "$base-$suffix",
        authUserId = config.userId?.let { userId ->
            if (suffix == null) userId else "$userId-$suffix"
        },
    )
}

/**
 * A stamped id for an ephemeral chat opening now. Saved as it is, and read
 * back through [ephemeralIdOf].
 */
internal fun newEphemeralStamp(): String = "$run$STAMP_SEPARATOR${UUID.randomUUID()}"

/**
 * The id [stamp] stands for, or a new one when it was minted by an earlier run
 * of the app.
 *
 * Saved state outlives the process while the conversation it names has been
 * swept by the time it comes back, and reusing its id would ask the backend
 * for the very conversation that was meant to be gone. A stamp from an earlier
 * run is answered with a new id, and the same one every time it is asked
 * about, so a rotation after that still keeps the conversation.
 */
internal fun ephemeralIdOf(stamp: String): String = when {
    stamp.startsWith("$run$STAMP_SEPARATOR") -> stamp.substringAfter(STAMP_SEPARATOR)
    else -> replacements.computeIfAbsent(stamp) { UUID.randomUUID().toString() }
}

/** This run of the app, which is what a stamp is stamped with. */
private val run: String = UUID.randomUUID().toString()
private val replacements = ConcurrentHashMap<String, String>()
private const val STAMP_SEPARATOR = "|"

/**
 * [context] written the way `JSON.stringify` writes it, so the hash taken of
 * it matches the web SDK's.
 *
 * The keys are left in the order they were given rather than sorted, which is
 * also what the web SDK hashes. Handing in the same pairs in another order is
 * another session, on both clients.
 */
private fun jsonOf(context: Map<String, String>): String = context.entries
    .joinToString(separator = ",", prefix = "{", postfix = "}") { (key, value) ->
        "${quoted(key)}:${quoted(value)}"
    }

private fun quoted(text: String): String = buildString(text.length + 2) {
    append('"')
    for (character in text) {
        when {
            character == '"' -> append("\\\"")
            character == '\\' -> append("\\\\")
            character == '\b' -> append("\\b")
            character == '\u000C' -> append("\\f")
            character == '\n' -> append("\\n")
            character == '\r' -> append("\\r")
            character == '\t' -> append("\\t")
            character < ' ' -> append(String.format(Locale.ROOT, "\\u%04x", character.code))
            else -> append(character)
        }
    }
    append('"')
}
