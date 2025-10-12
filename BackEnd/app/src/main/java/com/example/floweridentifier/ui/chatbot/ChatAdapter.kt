package com.example.floweridentifier.ui.chatbot

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.RecyclerView.ViewHolder
import com.example.floweridentifier.R
import com.example.floweridentifier.data.model.Message
import com.example.floweridentifier.databinding.ItemReceiveBinding
import com.example.floweridentifier.databinding.ItemSendBinding
import com.example.floweridentifier.utils.Utils

class ChatAdapter(
    private val list: List<Message>,
    private val copyText: (String) -> Unit
) :
    RecyclerView.Adapter<ViewHolder>() {

    class SendVH(private val binding: ItemSendBinding) :
        ViewHolder(binding.root) {
        fun onBind(item: Message) = binding.run {
            val text = item.content
            tvBody.text = text
            val dateFormatToTimeHour: String =
                Utils.dateFormatToTimeHour(item.created)
            tvTimeAgoRight.text = dateFormatToTimeHour
        }
    }

    class ReceiveVH(
        private val binding: ItemReceiveBinding
    ) :
        ViewHolder(binding.root) {
        fun onBind(item: Message) = binding.run {
            if (item.content.isEmpty()) {
                tvBody.text = root.context.getString(R.string.typing)
                tvBody.setTextColor(ContextCompat.getColor(root.context, R.color.gray))
                tvTimeAgoRight.visibility = View.GONE
            } else {
                tvTimeAgoRight.visibility = View.VISIBLE
                tvBody.text = item.content
                tvBody.setTextColor(ContextCompat.getColor(root.context, R.color.green_pri))
                val dateFormatToTimeHour: String =
                    Utils.dateFormatToTimeHour(item.created)
                tvTimeAgoRight.text = dateFormatToTimeHour
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) = when (viewType) {
        CHAT_BOT_TYPE -> ReceiveVH(
            ItemReceiveBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
        )

        else -> SendVH(ItemSendBinding.inflate(LayoutInflater.from(parent.context), parent, false))
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        (holder as? ReceiveVH)?.onBind(list[position])
        (holder as? SendVH)?.onBind(list[position])
    }

    override fun getItemViewType(position: Int) = if (!list[position].user.isCurrentUser) {
        CHAT_BOT_TYPE
    } else {
        USER_TYPE
    }

    override fun getItemCount(): Int {
        return list.size
    }

    companion object {
        const val CHAT_BOT_TYPE = 0
        const val USER_TYPE = 1
    }
}