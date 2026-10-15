// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages

import ai.yalo.chat.sdk.R
import ai.yalo.chat.sdk.domain.models.FeedbackRating
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.IconToggleButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp

internal const val CHAT_THUMBS_UP_TAG: String = "yalo-chat-thumbs-up-button"
internal const val CHAT_THUMBS_DOWN_TAG: String = "yalo-chat-thumbs-down-button"

/**
 * The thumbs up and thumbs down under an agent message.
 *
 * The one matching [selected] is drawn filled and reads as on. Tapping either
 * calls [onRate] with its rating, whether it is the one already picked or not,
 * because what a tap means is decided by the view model.
 */
@Composable
internal fun FeedbackButtons(
    selected: FeedbackRating?,
    onRate: (FeedbackRating) -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(modifier = modifier) {
        FeedbackButton(
            rating = FeedbackRating.ThumbsUp,
            selected = selected,
            onRate = onRate,
            icon = R.drawable.yalo_chat_ic_thumb_up,
            selectedIcon = R.drawable.yalo_chat_ic_thumb_up_filled,
            description = R.string.yalo_chat_thumbs_up_description,
            tag = CHAT_THUMBS_UP_TAG,
        )
        FeedbackButton(
            rating = FeedbackRating.ThumbsDown,
            selected = selected,
            onRate = onRate,
            icon = R.drawable.yalo_chat_ic_thumb_down,
            selectedIcon = R.drawable.yalo_chat_ic_thumb_down_filled,
            description = R.string.yalo_chat_thumbs_down_description,
            tag = CHAT_THUMBS_DOWN_TAG,
        )
    }
}

@Composable
private fun FeedbackButton(
    rating: FeedbackRating,
    selected: FeedbackRating?,
    onRate: (FeedbackRating) -> Unit,
    @DrawableRes icon: Int,
    @DrawableRes selectedIcon: Int,
    @StringRes description: Int,
    tag: String,
) {
    val theme = currentChatTheme
    val checked = rating == selected
    IconToggleButton(
        checked = checked,
        onCheckedChange = { onRate(rating) },
        modifier = Modifier
            .size(36.dp)
            .testTag(tag),
        colors = IconButtonDefaults.iconToggleButtonColors(
            contentColor = theme.onBackground,
            checkedContentColor = theme.onBackground,
        ),
    ) {
        Icon(
            painter = painterResource(if (checked) selectedIcon else icon),
            contentDescription = stringResource(description),
            modifier = Modifier.size(18.dp),
        )
    }
}
