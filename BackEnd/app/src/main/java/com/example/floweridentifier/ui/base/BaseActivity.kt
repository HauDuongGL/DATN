package com.example.floweridentifier.ui.base

import android.os.Bundle
import android.os.SystemClock
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.viewbinding.ViewBinding
import es.dmoral.toasty.Toasty
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

abstract class BaseActivity<B : ViewBinding> : AppCompatActivity() {
    protected lateinit var binding: B
    private var permissionComplete: ((Boolean) -> Unit)? = null
    private var lastClickTime: Long = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(null)
        binding = viewBinding()
        setContentView(binding.root)
        initView()
        initData()
        initListener()
    }

    protected abstract fun initView()
    protected abstract fun initData()
    protected abstract fun initListener()
    protected abstract fun viewBinding(): B

    fun aVoidDoubleClick(): Boolean {
        if (SystemClock.elapsedRealtime() - lastClickTime < 500) {
            return true
        }
        lastClickTime = SystemClock.elapsedRealtime()
        return false
    }

    fun toastInfo(content: String?) {
        lifecycleScope.launch(Dispatchers.Main) {
            content?.let { Toasty.info(this@BaseActivity, content, Toast.LENGTH_SHORT).show() }
        }
    }

    fun toastSuccess(content: String?) {
        lifecycleScope.launch(Dispatchers.Main) {
            content?.let { Toasty.success(this@BaseActivity, content, Toast.LENGTH_SHORT).show() }
        }
    }

    fun toastError(content: String?) {
        lifecycleScope.launch(Dispatchers.Main) {
            content?.let { Toasty.error(this@BaseActivity, content, Toast.LENGTH_SHORT).show() }
        }
    }

    fun toastWarning(content: String?) {
        lifecycleScope.launch(Dispatchers.Main) {
            content?.let { Toasty.warning(this@BaseActivity, content, Toast.LENGTH_SHORT).show() }
        }
    }
}
