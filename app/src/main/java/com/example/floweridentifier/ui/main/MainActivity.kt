package com.example.floweridentifier.ui.main

import android.app.Activity
import android.content.Intent
import android.graphics.RenderEffect
import android.graphics.Shader
import android.net.Uri
import android.os.Build
import android.util.Log
import android.view.LayoutInflater
import android.view.WindowManager
import android.widget.Toast
import com.example.floweridentifier.R
import com.example.floweridentifier.databinding.ActivityMainBinding
import com.example.floweridentifier.extension.imagePicker
import com.example.floweridentifier.ui.base.BaseActivity
import com.example.floweridentifier.ui.descflower.DescriptionFlowerActivity
import com.example.floweridentifier.ui.recognition.RecognitionActivity
import com.github.dhaval2404.imagepicker.ImagePicker

class MainActivity : BaseActivity<ActivityMainBinding>() {
    private val pagerAdapter by lazy(LazyThreadSafetyMode.NONE) {
        MainPagerAdapter(supportFragmentManager, lifecycle)
    }

    override fun initView() = binding.run {

        window.setFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )

        vpMain.run {
            adapter = pagerAdapter
            offscreenPageLimit = 3
            isUserInputEnabled = false  // Disable viewpager swipe
            isSaveEnabled = false
        }
        botNav.run {
            menu.getItem(1).isEnabled = false
            setOnItemSelectedListener {
                setViewPagerSelected(it.itemId)
                true
            }
        }
    }

    override fun initData() {
    }

    override fun initListener() {
        binding.imgScan.setOnClickListener {
            this.imagePicker()
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            binding.imgBg.setRenderEffect(RenderEffect.createBlurEffect(100F, 100F, Shader.TileMode.MIRROR))
        }
    }

    private fun setViewPagerSelected(itemId: Int) = binding.run {
        when (itemId) {
            R.id.itemHome -> vpMain.setCurrentItem(0, false)
            else -> vpMain.setCurrentItem(1, false)
        }
    }

    override fun viewBinding(): ActivityMainBinding =
        ActivityMainBinding.inflate(LayoutInflater.from(this))

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (resultCode) {
            Activity.RESULT_OK -> {
                //Image Uri will not be null for RESULT_OK
                val uri: Uri = data?.data!!

                // Use Uri object instead of File to avoid storage permissions
                startActivity(Intent(this, RecognitionActivity::class.java).apply {
                    putExtra("URI",uri.toString())
                })
            }
            ImagePicker.RESULT_ERROR -> {
                Toast.makeText(this, ImagePicker.getError(data), Toast.LENGTH_SHORT).show()
            }
            else -> {
                Toast.makeText(this, "Task Cancelled", Toast.LENGTH_SHORT).show()
            }
        }
    }
}

