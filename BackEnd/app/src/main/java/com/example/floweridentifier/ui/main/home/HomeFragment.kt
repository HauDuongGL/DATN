package com.example.floweridentifier.ui.main.home

import android.content.Intent
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import com.example.floweridentifier.databinding.HomeFragBinding
import com.example.floweridentifier.extension.imagePicker
import com.example.floweridentifier.ui.base.BaseFragment
import com.example.floweridentifier.ui.chatbot.ChatActivity
import com.example.floweridentifier.ui.descflower.DescriptionFlowerActivity
import com.example.floweridentifier.ui.main.home.adapter.FlowerAdapter
import com.github.dhaval2404.imagepicker.ImagePicker
import org.koin.androidx.viewmodel.ext.android.viewModel


class HomeFragment : BaseFragment<HomeFragBinding>() {
    private val viewModel by viewModel<HomeVM>()

    private val flowersRecent = mutableListOf<Any>()

    override fun initView() = binding.run {
        rvRecentFlower.adapter = FlowerAdapter(flowersRecent) {
            startActivity(
                Intent(
                    requireContext(),
                    DescriptionFlowerActivity::class.java
                ).apply {
                    putExtra("NAME_FLOWER", it)
                })
        }
    }

    override fun initData() {

    }

    override fun initListener() {
        viewModel.flowersRecent.observe(this@HomeFragment) {
            binding.lnlBanner.isVisible = it.isEmpty()
            flowersRecent.clear()
            flowersRecent.addAll(it)
            binding.rvRecentFlower.adapter?.notifyDataSetChanged()
        }
//        binding.imgGpt.setOnClickListener {
//            startActivity(Intent(requireContext(), ChatActivity::class.java))
//        }

        binding.btnScan.setOnClickListener {
            requireActivity().imagePicker()
        }

        binding.btnScan2.setOnClickListener {
            requireActivity().imagePicker()
        }

        binding.btnChat.setOnClickListener {
            startActivity(Intent(requireContext(), ChatActivity::class.java))
        }
    }

    override fun getViewBinding(inflater: LayoutInflater, container: ViewGroup?): HomeFragBinding =
        HomeFragBinding.inflate(inflater)
}