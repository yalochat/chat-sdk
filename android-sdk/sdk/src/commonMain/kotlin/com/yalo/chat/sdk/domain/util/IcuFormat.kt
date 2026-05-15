// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.util

import kotlin.math.round

// Resolves an ICU plural pattern for a given amount.
//
// Handles the subset used by product unit names:
//   {amount, plural, =1 {caja} other {cajas}}
//   {amount, plural, one {box} other {boxes}}
//
// Matching priority:
//   1. Exact match  — =N where N == round(amount)
//   2. CLDR keyword — zero(0), one(1), other(2+)
//   3. "other"      — ultimate fallback
//   4. Original pattern unchanged if nothing matched
//
// If pattern contains no ICU syntax (plain string like "kg"), returns it as-is.
internal fun formatIcuUnit(amount: Double, pattern: String): String {
    if (!pattern.contains('{')) return pattern
    val inner = ICU_PLURAL_RE.find(pattern.trim())?.groupValues?.get(1) ?: return pattern
    val amountRounded = round(amount).toLong()
    val cases = parseCases(inner)
    return cases["=$amountRounded"]
        ?: cases[cldrCategory(amountRounded)]
        ?: cases["other"]
        ?: pattern
}

// Regex matches the outer plural wrapper and captures the cases string.
// DOT_MATCHES_ALL lets (.*) span the nested { } of each case value.
private val ICU_PLURAL_RE = Regex(
    """\{[^,]+,\s*plural\s*,\s*(.*)\}""",
    setOf(RegexOption.DOT_MATCHES_ALL),
)

// Each case: keyword-or-=N followed by {text}.
// [^}]* is safe here because case values in product unit names are plain words.
private val CASE_RE = Regex("""(\S+)\s*\{([^}]*)\}""")

private fun parseCases(casesStr: String): Map<String, String> =
    CASE_RE.findAll(casesStr).associate { it.groupValues[1] to it.groupValues[2] }

private fun cldrCategory(amount: Long): String = when (amount) {
    0L -> "zero"
    1L -> "one"
    else -> "other"
}
