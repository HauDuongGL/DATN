package com.example.floweridentifier.ui.descflower

import android.content.Context
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isGone
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.bitmap.RoundedCorners
import com.example.floweridentifier.databinding.ItemFlowerThemeBinding

class ImageAdapter(private val images: MutableList<String>) :
    RecyclerView.Adapter<ImageAdapter.ImageViewHolder>() {
    inner class ImageViewHolder(
        private val binding: ItemFlowerThemeBinding,
        private val context: Context
    ) :
        RecyclerView.ViewHolder(binding.root) {
        fun onBind(urlImage: String) {
            binding.tvTheme.isGone = true
            Glide.with(context)
                .load(urlImage)
                .transform(RoundedCorners(4))
                .into(binding.imgTheme)
        }

    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) = ImageViewHolder(
        ItemFlowerThemeBinding.inflate(LayoutInflater.from(parent.context), parent, false),
        parent.context
    )

    override fun getItemCount() = images.size

    override fun onBindViewHolder(holder: ImageViewHolder, position: Int) =
        holder.onBind(images[position])
}