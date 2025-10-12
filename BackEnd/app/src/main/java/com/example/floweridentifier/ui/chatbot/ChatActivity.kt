package com.example.floweridentifier.ui.chatbot

import android.graphics.RenderEffect
import android.graphics.Shader
import android.os.Build
import android.view.LayoutInflater
import android.view.WindowManager
import androidx.core.view.isVisible
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.floweridentifier.R
import com.example.floweridentifier.databinding.ChatActBinding
import com.example.floweridentifier.ui.base.BaseActivity
import org.koin.androidx.viewmodel.ext.android.viewModel

class ChatActivity : BaseActivity<ChatActBinding>() {
    private val viewModel by viewModel<ChatViewModel>()
    override fun initView() = binding.run {
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

        rvChat.run {
            layoutManager = LinearLayoutManager(this@ChatActivity)
            adapter = ChatAdapter(viewModel.messagesList) {}
        }
    }

    override fun initData() {
        viewModel.getHistories()
        bindViewModel()
    }

    override fun initListener() = binding.run {
        tbChat.setNavigationOnClickListener {
            finish()
        }

        imgSend.setOnClickListener {
            if (!viewModel.isLoading) {
                val text = edtMessage.text.toString()
                if (text.isNotEmpty()) {
                    sendMessage(text)
                }
            } else {
                toastInfo(getString(R.string.please_wait))
            }
        }

        imgDelete.setOnClickListener {
            viewModel.clearHistories()
        }
    }

    private fun bindViewModel() = viewModel.run {
        messagesListLiveData.observe(this@ChatActivity) {
            binding.rvChat.adapter?.notifyDataSetChanged()
            binding.tvEmpty.isVisible = it.isEmpty()
            if (it.size > 1) {
                binding.rvChat.scrollToPosition(it.size - 1)
            }
        }
    }

    private fun sendMessage(text: String) = binding.run {
        viewModel.sendMessage(text)
        edtMessage.setText("")
    }

    override fun viewBinding() = ChatActBinding.inflate(LayoutInflater.from(this))

}