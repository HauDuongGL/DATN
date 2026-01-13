package com.example.floweridentifier.ui.notification

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.floweridentifier.data.model.NotificationItem
import com.example.floweridentifier.databinding.ItemNotificationBinding
import java.text.SimpleDateFormat
import java.util.Locale

class NotificationAdapter(
    private val onClick: (NotificationItem) -> Unit
) : RecyclerView.Adapter<NotificationAdapter.ViewHolder>() {

    private val items = mutableListOf<NotificationItem>()
    private val formatterIn = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
    private val formatterOut = SimpleDateFormat("dd MMM, HH:mm", Locale.getDefault())

    fun submit(list: List<NotificationItem>) {
        items.clear()
        items.addAll(list)
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemNotificationBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(items[position])
    }

    inner class ViewHolder(private val binding: ItemNotificationBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: NotificationItem) {
            binding.tvMessage.text = "${item.actorName ?: "Someone"} ${item.message}"
            binding.viewUnread.visibility = if (item.isRead) View.GONE else View.VISIBLE
            binding.tvTime.text = runCatching {
                val parsed = formatterIn.parse(item.createdAt)
                parsed?.let { formatterOut.format(it) } ?: ""
            }.getOrElse { "" }

            binding.root.setOnClickListener { onClick(item) }
        }
    }
}
