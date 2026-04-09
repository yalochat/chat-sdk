// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

// Bounded LRU cache used by YaloMessageRepositoryRemote to deduplicate inbound
// messages within the polling lookback window.
// Mirrors the ecache SimpleCache used in the Flutter SDK (capacity = 500).
internal class SimpleCache<K, V>(private val capacity: Int) {

    init {
        require(capacity > 0) { "capacity must be > 0, was $capacity" }
    }

    private val map = mutableMapOf<K, V>()
    // Tracks insertion/access order for LRU eviction.
    private val order = ArrayDeque<K>(capacity + 1)

    fun get(key: K): V? {
        val value = map[key] ?: return null
        // Promote to most-recently-used position (access-order LRU).
        order.remove(key)
        order.addLast(key)
        return value
    }

    fun set(key: K, value: V) {
        if (map.containsKey(key)) {
            order.remove(key)
        }
        map[key] = value
        order.addLast(key)
        if (order.size > capacity) {
            val eldest = order.removeFirst()
            map.remove(eldest)
        }
    }
}
