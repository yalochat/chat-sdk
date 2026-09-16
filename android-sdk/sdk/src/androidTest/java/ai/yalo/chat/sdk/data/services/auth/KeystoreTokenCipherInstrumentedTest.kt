// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.auth

import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Test
import org.junit.runner.RunWith
import java.security.GeneralSecurityException
import java.security.KeyStore

/**
 * The keystore only exists on a device, so this is the one part of storage
 * that cannot be covered by a unit test. Everything around it is, against a
 * cipher that stands in for this one.
 */
@RunWith(AndroidJUnit4::class)
class KeystoreTokenCipherInstrumentedTest {

    private val alias = "ai.yalo.chat.sdk.auth.test"
    private val cipher = KeystoreTokenCipher(alias)

    @After
    fun forgetKey() {
        KeyStore.getInstance("AndroidKeyStore").apply { load(null) }.deleteEntry(alias)
    }

    @Test
    fun readsBackWhatItEncrypted() {
        assertEquals("a refresh token", cipher.decrypt(cipher.encrypt("a refresh token")))
    }

    @Test
    fun leavesNoneOfTheTokenInTheEncryptedValue() {
        assertEquals(false, cipher.encrypt("a refresh token").contains("refresh"))
    }

    @Test
    fun encryptsTheSameTokenDifferentlyEveryTime() {
        assertNotEquals(cipher.encrypt("same token"), cipher.encrypt("same token"))
    }

    @Test
    fun keepsWorkingAcrossInstances() {
        val encrypted = KeystoreTokenCipher(alias).encrypt("a refresh token")

        assertEquals("a refresh token", KeystoreTokenCipher(alias).decrypt(encrypted))
    }

    @Test(expected = GeneralSecurityException::class)
    fun refusesAValueThatIsTooShortToHoldAnything() {
        cipher.decrypt("AAAA")
    }

    @Test(expected = GeneralSecurityException::class)
    fun refusesAValueTheKeyDidNotProduce() {
        val tampered = cipher.encrypt("a refresh token").replace('A', 'B')

        cipher.decrypt(tampered)
    }
}
