// Copyright (c) Yalochat, Inc. All rights reserved.

public class YaloChatClient(YaloChatClientConfig) {

    private val commands: Map<String, Function<*>> = ConcurrentHashMap()

    public fun registerCommand(val command: String, handler: Function<*>) {
	this.commands[command] = handler
    }
}
