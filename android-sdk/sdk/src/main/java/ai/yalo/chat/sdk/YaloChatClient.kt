// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

import java.util.concurrent.ConcurrentHashMap

public class YaloChatClient(internal val config: YaloChatClientConfig) {

    private val commands = ConcurrentHashMap<String, Function<*>>()

    public fun registerCommand(command: String, handler: Function<*>) {
	this.commands[command] = handler
    }

    public fun sendTextMessage(text: String) {

    }
}
