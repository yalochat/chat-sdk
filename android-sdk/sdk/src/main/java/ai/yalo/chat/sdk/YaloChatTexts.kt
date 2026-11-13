// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

/**
 * Your own copy for strings the chat would otherwise show in its built-in
 * translations. Named after the same setting in the web SDK so the two read
 * alike.
 *
 * A string given here is shown exactly as given whatever the device language,
 * so translating it is up to the app. Leave a field null to keep the built-in
 * translation.
 *
 * @property inputPlaceholder What the message input shows while it is empty.
 * @property imageNotAllowed The title of the alert shown when a picked picture
 * is turned away, because it is not a screenshot or its name is not allowed.
 * @property invalidImageAlertButtonText The button that closes that alert.
 */
public data class YaloChatTexts(
    public val inputPlaceholder: String? = null,
    public val imageNotAllowed: String? = null,
    public val invalidImageAlertButtonText: String? = null,
)
