package com.example.floweridentifier.ui.main.home.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.bitmap.RoundedCorners
import com.example.floweridentifier.R
import com.example.floweridentifier.data.model.Flower
import com.example.floweridentifier.data.model.response.Result
import com.example.floweridentifier.databinding.ItemFlowerBinding
import java.text.SimpleDateFormat

class FlowerAdapter(private val flowers: MutableList<Any>, val onClick: (String) -> Unit) :
    RecyclerView.Adapter<FlowerAdapter.FlowerViewHolder>() {
    inner class FlowerViewHolder(
        private val binding: ItemFlowerBinding,
        private val context: Context
    ) :
        RecyclerView.ViewHolder(binding.root) {
        fun onBind(flower: Any) {
            binding.run {
                when (flower) {
                    is Flower -> {
                        root.setOnClickListener {
                            onClick.invoke(flower.name)
                        }
                        tvNameFlower.text = flower.name
                        val formatter = SimpleDateFormat("dd/MM/yyyy")
                        tvDate.text = formatter.format(flower.addedAt)

                        fabFavorite.setImageResource(
                            if (flower.save)
                                R.drawable.ic_favorite_selected
                            else
                                R.drawable.ic_favorite
                        )
                        Glide.with(context)
                            .load(flower.imageRecognition)
                            .centerCrop()
                            .transform(RoundedCorners(8))
                            .into(imgFlower)
                    }

                    is Result -> {
                        root.setOnClickListener {
                            onClick.invoke(flower.nameFlower)
                        }
                        tvNameFlower.text = flower.nameFlower.capitalize()
                        tvDate.text = "Match rate: ${flower.matchRate}%"
                        tvArea.isVisible = flower.inArea
                        fabFavorite.isVisible = false

                        flower.imageUri?.let {
                            Glide.with(context)
                                .load(it)
                                .centerCrop()
                                .transform(RoundedCorners(8))
                                .into(imgFlower)
                        }
                    }

                    else -> {}
                }

            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) = FlowerViewHolder(
        ItemFlowerBinding.inflate(LayoutInflater.from(parent.context), parent, false),
        parent.context
    )

    override fun getItemCount() = flowers.size

    override fun onBindViewHolder(holder: FlowerViewHolder, position: Int) =
        holder.onBind(flowers[position])
}