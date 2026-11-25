// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import android.content.Context
import android.text.format.DateUtils
import org.robolectric.RuntimeEnvironment
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import java.util.Calendar

@RunWith(RobolectricTestRunner::class)
@Config(qualifiers = "en-rUS")
class DayLabelTest {

    private val context: Context = RuntimeEnvironment.getApplication()
    private val now: Long = at(2026, Calendar.NOVEMBER, 24)

    @Test
    fun namesTodayAndYesterday() {
        assertEquals("Today", dayLabelOf(context, now, now))
        assertEquals("Yesterday", dayLabelOf(context, now - DateUtils.DAY_IN_MILLIS, now))
    }

    @Test
    fun givesTheShortDateFromTwoDaysAgo() {
        assertEquals("Nov 22", dayLabelOf(context, at(2026, Calendar.NOVEMBER, 22), now))
        assertEquals("Oct 3", dayLabelOf(context, at(2026, Calendar.OCTOBER, 3), now))
    }

    @Test
    fun addsTheYearForAPastYear() {
        assertEquals("Nov 22, 2025", dayLabelOf(context, at(2025, Calendar.NOVEMBER, 22), now))
    }

    private fun at(year: Int, month: Int, day: Int): Long =
        Calendar.getInstance().apply { set(year, month, day, 12, 0, 0) }.timeInMillis
}
