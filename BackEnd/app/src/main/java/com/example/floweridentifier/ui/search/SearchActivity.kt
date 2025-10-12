package com.example.floweridentifier.ui.search

import android.content.Intent
import android.graphics.RenderEffect
import android.graphics.Shader
import android.os.Build
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.WindowManager
import androidx.core.view.isVisible
import com.example.floweridentifier.R
import com.example.floweridentifier.data.model.response.Result
import com.example.floweridentifier.databinding.SearchActBinding
import com.example.floweridentifier.ui.base.BaseActivity
import com.example.floweridentifier.ui.descflower.DescriptionFlowerActivity
import com.example.floweridentifier.ui.main.home.adapter.FlowerAdapter
import com.example.floweridentifier.ui.recognition.RecognitionVM
import com.example.floweridentifier.utils.ResponseState
import org.koin.androidx.viewmodel.ext.android.viewModel

class SearchActivity : BaseActivity<SearchActBinding>(){
    private val viewModel by viewModel<SearchVM>()

    private val resultFlower = mutableListOf<Any>()
    private var uri: String? = null
    override fun initView() {
        window.setFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            binding.imgBg.setRenderEffect(
                RenderEffect.createBlurEffect(
                    100F,
                    100F,
                    Shader.TileMode.MIRROR
                )
            )
        }

        binding.rvResultFlower.adapter = FlowerAdapter(resultFlower) {
            startActivity(
                Intent(
                    this@SearchActivity,
                    DescriptionFlowerActivity::class.java
                ).apply {
                    putExtra("NAME_FLOWER", it)
                    putExtra("URI", uri)
                })
        }
    }

    override fun initData() {
        var search = intent.getStringExtra("FLOWER_SEARCH")


    }

    override fun initListener() {
//        viewModel.resultRecognition.observe(this) {
//            when (it) {
//                is ResponseState.Loading -> {}
//
//                is ResponseState.Success -> {
//                    resultFlower.clear()
//                    resultFlower.addAll(it.item)
//                    resultFlower.forEach { flower ->
//                        if (flower is Result) {
//                            viewModel.getSimilarImage(flower.nameFlower) { uri ->
//                                flower.imageUri = uri
//                                binding.rvResultFlower.adapter?.notifyDataSetChanged()
//                            }
//
//                            flower.inArea = flower.areas.contains(area)
//                        }
//                    }
//
//                    binding.run {
//                        pbLoad.isVisible = false
//                        tvLoad.isVisible = false
//                        rvResultFlower.isVisible = true
//                        rvResultFlower.adapter?.notifyDataSetChanged()
//                    }
//                }
//
//                is ResponseState.Error -> {
//                    binding.run {
//                        pbLoad.isVisible = false
//                        tvLoad.text = getString(R.string.sorry_i_can_t_recognition_this_flower)
//                        Log.d("DTAG", "initListener: ${it.mess}")
//                    }
//                }
//
//                else -> {}
//            }
//        }

        binding.fabClose.setOnClickListener {
            finish()
        }
    }

    override fun viewBinding(): SearchActBinding = SearchActBinding.inflate(LayoutInflater.from(this))

}