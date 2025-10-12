package com.example.floweridentifier.ui.main.myplants

import android.content.Intent
import android.view.LayoutInflater
import android.view.ViewGroup
import com.example.floweridentifier.databinding.MyPlantsFragBinding
import com.example.floweridentifier.ui.base.BaseFragment
import com.example.floweridentifier.ui.chatbot.ChatActivity
import com.example.floweridentifier.ui.descflower.DescriptionFlowerActivity
import com.example.floweridentifier.ui.main.home.adapter.FlowerAdapter
import org.koin.androidx.viewmodel.ext.android.viewModel


class MyPlantsFragment : BaseFragment<MyPlantsFragBinding>() {
    private val viewModel by viewModel<MyPlantVM>()
    private val myFlowers = mutableListOf<Any>()
    override fun initView() {
        binding.rvMyFlower.adapter = FlowerAdapter(myFlowers) {
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
        viewModel.myFlowers.observe(this@MyPlantsFragment) {
            myFlowers.clear()
            myFlowers.addAll(it)
            binding.rvMyFlower.adapter?.notifyDataSetChanged()
        }
    }

    override fun getViewBinding(
        inflater: LayoutInflater,
        container: ViewGroup?
    ): MyPlantsFragBinding = MyPlantsFragBinding.inflate(inflater)
}