// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk


public data class YaloChatClientConfig(
    public val channelId: String,
    public val organizationId: String,
    public val channelName: String,
    public val userId: String? = null,
)
