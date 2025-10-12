package com.example.floweridentifier.ui.base

import android.os.Bundle
import android.os.SystemClock
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.viewbinding.ViewBinding

abstract class BaseFragment<B : ViewBinding> : Fragment() {
    protected lateinit var binding: B
    private var lastClickTime: Long = 0

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View? {
        binding = getViewBinding(inflater, container)
        return binding.root
    }


    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, null)
        initView()
        initData()
        initListener()
    }

    protected abstract fun initView()
    protected abstract fun initData()
    protected abstract fun initListener()
    protected abstract fun getViewBinding(inflater: LayoutInflater, container: ViewGroup?): B

    protected val baseActivity: BaseActivity<*>?
        get() = activity as BaseActivity<*>?

    fun toastInfo(content: String?) {
        baseActivity?.toastInfo(content)
    }

    fun toastSuccess(content: String?) {
        baseActivity?.toastSuccess(content)
    }

    fun toastWarning(content: String?) {
        baseActivity?.toastWarning(content)
    }

    fun toastError(content: String?) {
        baseActivity?.toastError(content)
    }

    fun backPress() {
        baseActivity?.onBackPressed()
    }

    fun aVoidDoubleClick(): Boolean {
        if (SystemClock.elapsedRealtime() - lastClickTime < 500) {
            return true
        }
        lastClickTime = SystemClock.elapsedRealtime()
        return false
    }

}