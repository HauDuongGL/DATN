package com.example.floweridentifier.ui.descflower

import android.content.Intent
import android.graphics.RenderEffect
import android.graphics.Shader
import android.net.Uri
import android.os.Build
import android.view.LayoutInflater
import android.view.WindowManager
import androidx.core.view.isVisible
import com.bumptech.glide.Glide
import com.example.floweridentifier.R
import com.example.floweridentifier.data.model.Flower
import com.example.floweridentifier.databinding.DescriptionFlowerActBinding
import com.example.floweridentifier.ui.base.BaseActivity
import com.example.floweridentifier.utils.RealPathUtil
import com.example.floweridentifier.utils.ResponseState
import org.koin.androidx.viewmodel.ext.android.viewModel
import java.io.File
import java.util.Date
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class DescriptionFlowerActivity : BaseActivity<DescriptionFlowerActBinding>() {
    private val viewModel by viewModel<FlowerVM>()
    private lateinit var flower: Flower
    private lateinit var file: File
    override fun initView() {
        window.setFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            binding.imgBg.setRenderEffect(RenderEffect.createBlurEffect(100F, 100F, Shader.TileMode.MIRROR))
        }
    }

    override fun initData() {
        val nameFlower = intent.getStringExtra("NAME_FLOWER")
        val uri = intent.getStringExtra("URI")
        if (uri != null) {
            file = File(RealPathUtil.getRealPath(this, Uri.parse(uri)))
            Glide.with(this@DescriptionFlowerActivity)
                .load(file.absolutePath)
                .into(binding.imgFlower)
        }
        if (nameFlower != null) {
            binding.tvNameFlower.text = nameFlower.replaceFirstChar { if (it.isLowerCase()) it.titlecase(java.util.Locale.ROOT) else it.toString() }

            val localFlower = viewModel.getDescFlower(nameFlower.lowercase())
            if (localFlower != null) {
                this.flower = localFlower
                setupData()
                binding.pbLoad.isVisible = false
                binding.tvLoad.isVisible = false
                binding.lnlInfo.isVisible = true
                if (uri == null) {
                    Glide.with(this@DescriptionFlowerActivity)
                        .load(flower.imageRecognition)
                        .into(binding.imgFlower)
                }
            } else {
                viewModel.descriptionFlower(nameFlower)
            }
        }
    }

    override fun initListener() {
        viewModel.flowerResponseState.observe(this) {
            when (it) {
                is ResponseState.Loading -> {}

                is ResponseState.Success -> {
                    this@DescriptionFlowerActivity.flower = it.item.apply {
                        addedAt = Date().time
                        imageRecognition = file.absolutePath
                    }
                    setupData()

                    binding.run {
                        pbLoad.isVisible = false
                        tvLoad.isVisible = false
                        lnlInfo.isVisible = true
                    }
                }

                else -> {
                    binding.run {
                        pbLoad.isVisible = false
                        tvLoad.text = getString(R.string.sorry_i_can_t_recognition_this_flower)
                    }
                }
            }
        }

        binding.fabFavorite.setOnClickListener {
            flower.save = true
            viewModel.insertFlower(flower)
            toastSuccess("Save successfully")
        }
        binding.btnBack.setOnClickListener {
            finish()
        }

        binding.fabShare.setOnClickListener {
            if (::flower.isInitialized) {
                shareToWeb()
            } else {
                toastSuccess("Vui lòng đợi dữ liệu tải xong")
            }
        }
    }

    private fun shareToWeb() {
        if (!com.example.floweridentifier.utils.PreferenceHelper.isLoggedIn(this)) {
            toastSuccess("Please login to share")
            startActivity(Intent(this, com.example.floweridentifier.ui.auth.LoginActivity::class.java))
            return
        }

        // Try to recover file from flower object if not initialized (e.g. from History)
        if (!::file.isInitialized && ::flower.isInitialized && !flower.imageRecognition.isNullOrEmpty()) {
            file = File(flower.imageRecognition)
        }

        if (!::file.isInitialized || !file.exists()) {
            toastSuccess("Image not found")
            return
        }

        binding.pbLoad.isVisible = true
        binding.fabShare.isEnabled = false

        CoroutineScope(Dispatchers.Main).launch {
            val userId = com.example.floweridentifier.utils.PreferenceHelper.getUserId(this@DescriptionFlowerActivity) ?: ""
            val token = com.example.floweridentifier.utils.PreferenceHelper.getToken(this@DescriptionFlowerActivity) ?: ""
            val repository = com.example.floweridentifier.data.repository.StorageRepository()
            
            val result = withContext(Dispatchers.IO) {
                repository.uploadImage(file, userId, token)
            }
            
            binding.pbLoad.isVisible = false
            binding.fabShare.isEnabled = true
            
            result.onSuccess { imageUrl ->
                val baseUrl = com.example.floweridentifier.utils.Constants.WEB_SHARE_URL
                val shareUrl = Uri.parse(baseUrl).buildUpon()
                    .appendQueryParameter("flowerName", flower.name)
                    .appendQueryParameter("flowerSpecies", flower.species)
                    .appendQueryParameter("description", flower.desc)
                    .appendQueryParameter("care", flower.care)
                    .appendQueryParameter("imageUrl", imageUrl)
                    .build()
                    .toString()

                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(shareUrl))
                startActivity(intent)
            }.onFailure {
                toastSuccess("Upload failed: ${it.message}")
            }
        }
    }

    private fun setupData() = binding.run {
        val urlImages = mutableListOf<String>()

        tvNameFlower.text = flower.name.replaceFirstChar { if (it.isLowerCase()) it.titlecase(java.util.Locale.ROOT) else it.toString() }
        tvDesc.text = flower.desc
        tvSpecies.text = flower.species
        tvCare.text = flower.care
        rvImages.adapter = ImageAdapter(urlImages)
        fabFavorite.setImageResource(if (flower.save) R.drawable.ic_favorite_selected else R.drawable.ic_favorite)

        viewModel.getSomeImages(flower.name, 5)
        viewModel.someImagesResponseState.observe(this@DescriptionFlowerActivity) {
            when (it) {
                is ResponseState.Loading -> {}

                is ResponseState.Success -> {
                    urlImages.clear()
                    urlImages.addAll(it.item)
                    rvImages.adapter?.notifyDataSetChanged()
                }

                else -> {
                    binding.run {
                        toastSuccess("Wellcom History")
                    }
                }
            }
        }

        viewModel.insertFlower(flower)
    }

    override fun viewBinding(): DescriptionFlowerActBinding = DescriptionFlowerActBinding.inflate(
        LayoutInflater.from(this)
    )
}