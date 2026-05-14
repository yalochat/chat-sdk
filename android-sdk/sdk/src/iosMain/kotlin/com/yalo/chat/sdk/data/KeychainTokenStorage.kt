// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data

import com.yalo.chat.sdk.data.remote.TokenStorage
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.NativePtr
import kotlinx.cinterop.addressOf
import kotlinx.cinterop.alloc
import kotlinx.cinterop.convert
import kotlinx.cinterop.interpretObjCPointer
import kotlinx.cinterop.memScoped
import kotlinx.cinterop.ptr
import kotlinx.cinterop.rawValue
import kotlinx.cinterop.usePinned
import kotlinx.cinterop.value
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import platform.CoreFoundation.CFDictionaryRef
import platform.CoreFoundation.CFTypeRefVar
import platform.Foundation.NSData
import platform.Foundation.NSMutableDictionary
import platform.Foundation.NSNumber
import platform.Foundation.NSString
import platform.Foundation.dataWithBytes
import platform.posix.memcpy
import platform.Security.SecItemAdd
import platform.Security.SecItemCopyMatching
import platform.Security.SecItemDelete
import platform.Security.kSecAttrAccessible
import platform.Security.kSecAttrAccessibleAfterFirstUnlock
import platform.Security.kSecAttrAccount
import platform.Security.kSecAttrService
import platform.Security.kSecClass
import platform.Security.kSecClassGenericPassword
import platform.Security.kSecMatchLimit
import platform.Security.kSecMatchLimitOne
import platform.Security.kSecReturnData
import platform.Security.kSecValueData

private const val KEYCHAIN_SERVICE = "com.yalo.chat.sdk.tokens"

// Security constants are CFStringRef (CPointer<__CFString>) — toll-free bridged to NSString.
// nsKey() converts each CF constant's raw pointer to a Kotlin/Native ObjC reference so it
// can be used as an NSMutableDictionary key (which requires NSCopyingProtocol at runtime).
@OptIn(ExperimentalForeignApi::class)
internal class KeychainTokenStorage(channelId: String) : TokenStorage {

    // Scope the Keychain account to channelId so re-init with a different channel never
    // loads a token issued for the previous channel.
    private val account = "tokens-$channelId"

    @Serializable
    private data class StoredTokens(
        val accessToken: String,
        val refreshToken: String,
        val expiresAt: Long,
    )

    override fun load(): TokenStorage.Entry? = try {
        val query = buildBaseQuery()
        // kSecReturnData value must be a CFBooleanRef — use NSNumber(bool) not interpretObjCPointer<NSString>.
        query.setObject(NSNumber(bool = true), forKey = nsKey(kSecReturnData!!.rawValue))
        // kSecMatchLimitOne ensures SecItemCopyMatching returns a single NSData, not an NSArray.
        query.setObject(nsKey(kSecMatchLimitOne!!.rawValue), forKey = nsKey(kSecMatchLimit!!.rawValue))
        memScoped {
            val result = alloc<CFTypeRefVar>()
            @Suppress("UNCHECKED_CAST")
            if (SecItemCopyMatching(query as CFDictionaryRef, result.ptr) != 0) return null
            @Suppress("UNCHECKED_CAST")
            val data = result.value as? NSData ?: return null
            val bytes = ByteArray(data.length.toInt())
            if (bytes.isNotEmpty()) {
                bytes.usePinned { memcpy(it.addressOf(0), data.bytes, data.length) }
            }
            val stored = Json.decodeFromString<StoredTokens>(bytes.decodeToString())
            TokenStorage.Entry(stored.accessToken, stored.refreshToken, stored.expiresAt)
        }
    } catch (_: Exception) {
        null
    }

    override fun save(entry: TokenStorage.Entry) {
        try {
            val json = Json.encodeToString(
                StoredTokens(entry.accessToken, entry.refreshToken, entry.expiresAt)
            )
            val bytes = json.encodeToByteArray()
            val data = bytes.usePinned { NSData.dataWithBytes(it.addressOf(0), bytes.size.convert()) }
                ?: return
            // Delete any existing item first to avoid the update/add branching.
            @Suppress("UNCHECKED_CAST")
            SecItemDelete(buildBaseQuery() as CFDictionaryRef)
            val attrs = buildBaseQuery()
            attrs.setObject(data, forKey = nsKey(kSecValueData!!.rawValue))
            attrs.setObject(nsKey(kSecAttrAccessibleAfterFirstUnlock!!.rawValue), forKey = nsKey(kSecAttrAccessible!!.rawValue))
            @Suppress("UNCHECKED_CAST")
            SecItemAdd(attrs as CFDictionaryRef, null)
        } catch (_: Exception) { }
    }

    override fun clear() {
        try {
            @Suppress("UNCHECKED_CAST")
            SecItemDelete(buildBaseQuery() as CFDictionaryRef)
        } catch (_: Exception) { }
    }

    private fun buildBaseQuery(): NSMutableDictionary {
        val q = NSMutableDictionary()
        q.setObject(nsKey(kSecClassGenericPassword!!.rawValue), forKey = nsKey(kSecClass!!.rawValue))
        q.setObject(KEYCHAIN_SERVICE, forKey = nsKey(kSecAttrService!!.rawValue))
        // kSecAttrAccount makes the item uniquely addressable within the service.
        q.setObject(account, forKey = nsKey(kSecAttrAccount!!.rawValue))
        return q
    }

    private fun nsKey(rawPtr: NativePtr): NSString = interpretObjCPointer(rawPtr)
}
