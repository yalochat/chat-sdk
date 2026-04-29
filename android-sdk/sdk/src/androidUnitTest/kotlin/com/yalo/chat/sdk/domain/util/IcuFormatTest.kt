// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.util

import org.junit.Assert.assertEquals
import org.junit.Test

class IcuFormatTest {

    // ── Plain strings (no ICU syntax) ─────────────────────────────────────────

    @Test fun `plain string is returned as-is`() {
        assertEquals("kg", formatIcuUnit(3.0, "kg"))
    }

    @Test fun `empty string is returned as-is`() {
        assertEquals("", formatIcuUnit(1.0, ""))
    }

    // ── Exact match (=N) ──────────────────────────────────────────────────────

    @Test fun `exact match =1 for amount 1`() {
        val pattern = "{amount, plural, =1 {caja} other {cajas}}"
        assertEquals("caja", formatIcuUnit(1.0, pattern))
    }

    @Test fun `exact match =0 for amount 0`() {
        val pattern = "{amount, plural, =0 {ninguna} other {cajas}}"
        assertEquals("ninguna", formatIcuUnit(0.0, pattern))
    }

    @Test fun `exact match =2 for amount 2`() {
        val pattern = "{amount, plural, =1 {unit} =2 {pair} other {units}}"
        assertEquals("pair", formatIcuUnit(2.0, pattern))
    }

    // ── CLDR keywords ─────────────────────────────────────────────────────────

    @Test fun `one keyword for amount 1 when no exact match`() {
        val pattern = "{amount, plural, one {box} other {boxes}}"
        assertEquals("box", formatIcuUnit(1.0, pattern))
    }

    @Test fun `other keyword for amount 3`() {
        val pattern = "{amount, plural, =1 {caja} other {cajas}}"
        assertEquals("cajas", formatIcuUnit(3.0, pattern))
    }

    @Test fun `zero keyword for amount 0`() {
        val pattern = "{amount, plural, zero {nothing} other {items}}"
        assertEquals("nothing", formatIcuUnit(0.0, pattern))
    }

    // ── Rounding ──────────────────────────────────────────────────────────────

    @Test fun `0_9 rounds to 1 — exact match applies`() {
        val pattern = "{amount, plural, =1 {caja} other {cajas}}"
        assertEquals("caja", formatIcuUnit(0.9, pattern))
    }

    @Test fun `1_4 rounds to 1 — exact match applies`() {
        val pattern = "{amount, plural, =1 {caja} other {cajas}}"
        assertEquals("caja", formatIcuUnit(1.4, pattern))
    }

    @Test fun `1_6 rounds to 2 — falls through to other`() {
        val pattern = "{amount, plural, =1 {caja} other {cajas}}"
        assertEquals("cajas", formatIcuUnit(1.6, pattern))
    }

    // ── Malformed / unrecognised patterns ─────────────────────────────────────

    @Test fun `pattern without plural keyword returned as-is`() {
        val pattern = "{amount, select, male {él} other {ella}}"
        assertEquals(pattern, formatIcuUnit(1.0, pattern))
    }

    @Test fun `pattern with no matching case falls back to original`() {
        val pattern = "{amount, plural, =5 {five}}"
        assertEquals(pattern, formatIcuUnit(1.0, pattern))
    }

    // ── Flutter parity (from format_test.dart) ────────────────────────────────

    @Test fun `flutter parity - formatUnit(3, pattern) returns cajas`() {
        val pattern = "{amount, plural, =1 {caja} other {cajas}}"
        assertEquals("cajas", formatIcuUnit(3.0, pattern))
    }

    @Test fun `flutter parity - formatUnit(1, pattern) returns caja`() {
        val pattern = "{amount, plural, =1 {caja} other {cajas}}"
        assertEquals("caja", formatIcuUnit(1.0, pattern))
    }

    @Test fun `flutter parity - plain string passes through`() {
        assertEquals("caja", formatIcuUnit(3.0, "caja"))
    }
}
