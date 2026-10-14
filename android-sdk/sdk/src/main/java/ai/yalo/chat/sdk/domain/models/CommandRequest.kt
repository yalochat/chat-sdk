// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.domain.models

/**
 * The channel asking the host app to run [commandId] with [payload].
 *
 * [correlationId] goes back on the answer, so the channel knows which request
 * it belongs to, and [kind] says which response the answer has to be.
 */
internal data class CommandRequest(
    val correlationId: String,
    val commandId: String,
    val payload: String,
    val kind: Kind = Kind.Custom,
) {

    enum class Kind { Custom, GetCart, UpdateCartProduct }
}
