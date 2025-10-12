package com.example.floweridentifier.ui.main.home.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.floweridentifier.data.model.Theme
import com.example.floweridentifier.databinding.ItemFlowerThemeBinding

class ThemeAdapter(private val themes: MutableList<Theme>, val onClick: (Theme) -> Unit) :
    RecyclerView.Adapter<ThemeAdapter.ThemeHolder>() {
    inner class ThemeHolder(private val binding: ItemFlowerThemeBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun onBind(theme: Theme) {
            binding.run {
                root.setOnClickListener {
                    onClick.invoke(theme)
                }
                imgTheme.setImageResource(theme.image)
                tvTheme.text = theme.name
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) = ThemeHolder(
        ItemFlowerThemeBinding.inflate(LayoutInflater.from(parent.context), parent, false)
    )

    override fun getItemCount() = themes.size

    override fun onBindViewHolder(holder: ThemeHolder, position: Int) =
        holder.onBind(themes[position])
}