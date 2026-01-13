package com.example.floweridentifier.ui.recognition

import android.content.Intent
import android.graphics.RenderEffect
import android.graphics.Shader
import android.net.Uri
import android.os.Build
import android.util.Log
import android.view.LayoutInflater
import android.view.WindowManager
import androidx.appcompat.app.AlertDialog
import androidx.core.view.isVisible
import com.bumptech.glide.Glide
import com.example.floweridentifier.R
import com.example.floweridentifier.data.model.response.Result
import com.example.floweridentifier.databinding.DialogAreaBinding
import com.example.floweridentifier.databinding.RecognitionActBinding
import com.example.floweridentifier.ui.base.BaseActivity
import com.example.floweridentifier.ui.descflower.DescriptionFlowerActivity
import com.example.floweridentifier.ui.main.home.adapter.FlowerAdapter
import com.example.floweridentifier.utils.RealPathUtil
import com.example.floweridentifier.utils.ResponseState
import org.koin.androidx.viewmodel.ext.android.viewModel
import java.io.File

class RecognitionActivity : BaseActivity<RecognitionActBinding>() {
    private val viewModel by viewModel<RecognitionVM>()

    private val resultFlower = mutableListOf<Any>()
    private var uri: String? = null
    private var area: String = "Unknown"
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
                    this@RecognitionActivity,
                    DescriptionFlowerActivity::class.java
                ).apply {
                    putExtra("NAME_FLOWER", it)
                    putExtra("URI", uri)
                })
        }
    }

    override fun initData() {
        Log.d("RecognitionActivity", "initData() called")
        uri = intent.getStringExtra("URI")
        Log.d("RecognitionActivity", "URI from intent: $uri")
        if (uri != null) {
            try {
                val realPath = RealPathUtil.getRealPath(this, Uri.parse(uri))
                Log.d("RecognitionActivity", "Real path: $realPath")
                val file = File(realPath)
                Log.d("RecognitionActivity", "File created: ${file.absolutePath}, exists: ${file.exists()}")
                
                Glide.with(this@RecognitionActivity)
                    .load(file.absolutePath)
                    .into(binding.imgFlower)

                showDialogArea(file)
            } catch (e: Exception) {
                Log.e("RecognitionActivity", "Error in initData", e)
            }
        } else {
            Log.e("RecognitionActivity", "URI is null!")
        }
    }

    override fun initListener() {
        viewModel.resultRecognition.observe(this) {
            when (it) {
                is ResponseState.Loading -> {}

                is ResponseState.Success -> {
                    resultFlower.clear()
                    resultFlower.addAll(it.item)
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

                    binding.run {
                        pbLoad.isVisible = false
                        tvLoad.isVisible = false
                        rvResultFlower.isVisible = true
                        rvResultFlower.adapter?.notifyDataSetChanged()
                    }
                }

                is ResponseState.Error -> {
                    binding.run {
                        pbLoad.isVisible = false
                        tvLoad.text = getString(R.string.sorry_i_can_t_recognition_this_flower)
                        Log.e("RecognitionActivity", "Error: ${it.mess}")
                        Log.e("RecognitionActivity", "Full error details", Exception(it.mess))
                    }
                }

                else -> {}
            }
        }

        binding.fabClose.setOnClickListener {
            finish()
        }
    }

    private fun showDialogArea(file: File) {
        Log.d("RecognitionActivity", "showDialogArea called with file: ${file.absolutePath}, exists: ${file.exists()}")
        
        val dialogBinding = DialogAreaBinding.inflate(LayoutInflater.from(this))

        val alertDialog =
            AlertDialog.Builder(this, R.style.AppCompat_AlertDialog).setView(dialogBinding.root)
                .setCancelable(false)
                .create()
        dialogBinding.run {
            rdGr.setOnCheckedChangeListener { _, checkedId ->
                area = when (checkedId) {
                    cb0.id -> cb0.text.toString()
                    cb1.id -> cb1.text.toString()
                    cb2.id -> cb2.text.toString()
                    cb3.id -> cb3.text.toString()
                    cb4.id -> cb4.text.toString()
                    cb5.id -> cb5.text.toString()
                    cb6.id -> cb6.text.toString()
                    else -> "Unknown"
                }
                tvNext.text = "Next"
            }
            tvNext.setOnClickListener {
                Log.d("RecognitionActivity", "Next clicked, calling recognizeFlower with area: $area")
                viewModel.recognizeFlower(file, area)
                alertDialog.dismiss()
            }
        }

        alertDialog.show()
    }

    override fun viewBinding() = RecognitionActBinding.inflate(LayoutInflater.from(this))

}