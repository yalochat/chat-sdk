// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

// Bounded LRU cache used by YaloMessageRepositoryRemote to deduplicate inbound
// messages within the polling lookback window.
// Mirrors the ecache SimpleCache used in the Flutter SDK (capacity = 500).
// Thread-safe via @Synchronized on each accessor.
internal class SimpleCache<K, V>(private val capacity: Int) {

    init {
        require(capacity > 0) { "capacity must be > 0, was $capacity" }
    }


    // accessOrder = true → LinkedHashMap maintains LRU order; removeEldestEntry
    // evicts when size exceeds capacity, keeping memory bounded.
    private val map: LinkedHashMap<K, V> = object : LinkedHashMap<K, V>(
        (capacity * 1.34f + 1).toInt(), 0.75f, /* accessOrder = */ true,
    ) {
        override fun removeEldestEntry(eldest: Map.Entry<K, V>): Boolean = size > capacity
    }

    @Synchronized
    fun get(key: K): V? = map[key]

    @Synchronized
    fun set(key: K, value: V) {
        map[key] = value
    }
}
