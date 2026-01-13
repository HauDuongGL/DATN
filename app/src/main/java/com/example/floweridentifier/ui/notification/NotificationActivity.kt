package com.example.floweridentifier.ui.notification

import androidx.recyclerview.widget.LinearLayoutManager
import androidx.lifecycle.lifecycleScope
import com.example.floweridentifier.data.repository.NotificationRepository
import com.example.floweridentifier.databinding.ActivityNotificationBinding
import com.example.floweridentifier.ui.base.BaseActivity
import com.example.floweridentifier.utils.PreferenceHelper
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class NotificationActivity : BaseActivity<ActivityNotificationBinding>() {
    private val repo = NotificationRepository()
    private val adapter = NotificationAdapter { item ->
        // Mark read on click
        lifecycleScope.launch {
            repo.markAsRead(this@NotificationActivity, item.id)
        }
    }

    override fun initView() = binding.run {
        toolbar.setNavigationOnClickListener { onBackPressedDispatcher.onBackPressed() }
        rvNotifications.layoutManager = LinearLayoutManager(this@NotificationActivity)
        rvNotifications.adapter = adapter
    }

    override fun initData() {
        loadNotifications()
    }

    override fun initListener() {
        binding.btnMarkAll.setOnClickListener {
            lifecycleScope.launch {
                val result = repo.markAllAsRead(this@NotificationActivity)
                if (result.isSuccess) {
                    toastSuccess("Đã đánh dấu tất cả đã đọc")
                    loadNotifications()
                } else {
                    toastError(result.exceptionOrNull()?.message)
                }
            }
        }
    }

    private fun loadNotifications() {
        binding.tvStatus.visibility = android.view.View.VISIBLE
        binding.tvStatus.text = binding.root.context.getString(com.example.floweridentifier.R.string.loading_notifications)
        lifecycleScope.launch(Dispatchers.IO) {
            val result = repo.fetchNotifications(this@NotificationActivity)
            withContext(Dispatchers.Main) {
                binding.tvStatus.visibility = android.view.View.GONE
                if (result.isSuccess) {
                    val data = result.getOrNull().orEmpty()
                    adapter.submit(data)
                    if (data.isEmpty()) {
                        binding.tvStatus.visibility = android.view.View.VISIBLE
                        binding.tvStatus.text = binding.root.context.getString(com.example.floweridentifier.R.string.no_notifications)
                    }
                } else {
                    val msg = result.exceptionOrNull()?.message
                    if (msg == "JWT_EXPIRED") {
                        PreferenceHelper.clear(this@NotificationActivity)
                        toastWarning("Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại")
                        onBackPressedDispatcher.onBackPressed()
                    } else {
                        binding.tvStatus.visibility = android.view.View.VISIBLE
                        binding.tvStatus.text = msg ?: "Failed to load"
                        toastError(msg)
                    }
                }
            }
        }
    }

    override fun viewBinding(): ActivityNotificationBinding =
        ActivityNotificationBinding.inflate(layoutInflater)
}
