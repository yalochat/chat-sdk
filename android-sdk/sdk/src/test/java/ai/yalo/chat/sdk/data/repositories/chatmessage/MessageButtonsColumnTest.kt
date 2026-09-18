// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.chatmessage

import ai.yalo.chat.sdk.domain.models.MessageButton
import ai.yalo.chat.sdk.domain.models.MessageButtonType
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class MessageButtonsColumnTest {

    @Test
    fun readsBackEveryButtonItWasGiven() {
        val buttons = listOf(
            MessageButton(text = "Yes"),
            MessageButton(text = "Track it", type = MessageButtonType.Postback),
            MessageButton(
                text = "Open the store",
                type = MessageButtonType.Link,
                url = "https://yalo.com",
            ),
        )

        assertEquals(buttons, MessageButtonsColumn.decode(MessageButtonsColumn.encode(buttons)))
    }

    @Test
    fun writesNothingForAMessageWithNoButtons() {
        assertNull(MessageButtonsColumn.encode(emptyList()))
    }

    @Test
    fun readsAnEmptyColumnAsNoButtons() {
        assertEquals(emptyList<MessageButton>(), MessageButtonsColumn.decode(null))
        assertEquals(emptyList<MessageButton>(), MessageButtonsColumn.decode(""))
    }

    // A row written by something else is not worth losing the conversation over.
    @Test
    fun readsSomethingThatIsNotAListOfButtonsAsNoButtons() {
        assertEquals(emptyList<MessageButton>(), MessageButtonsColumn.decode("not json"))
        assertEquals(emptyList<MessageButton>(), MessageButtonsColumn.decode("""{"text":"Yes"}"""))
    }

    @Test
    fun leavesOutAButtonWithNothingWrittenOnIt() {
        val stored = """[{"text":""},{"text":"Yes","type":"reply"}]"""

        assertEquals(listOf("Yes"), MessageButtonsColumn.decode(stored).map { it.text })
    }

    @Test
    fun leavesOutAnEntryThatIsNotAButton() {
        val stored = """["Yes",{"text":"No"}]"""

        assertEquals(listOf("No"), MessageButtonsColumn.decode(stored).map { it.text })
    }

    @Test
    fun readsAKindItDoesNotKnowAsAnAnswer() {
        val stored = """[{"text":"Yes","type":"something-newer"}]"""

        assertEquals(MessageButtonType.Reply, MessageButtonsColumn.decode(stored).single().type)
    }
}
