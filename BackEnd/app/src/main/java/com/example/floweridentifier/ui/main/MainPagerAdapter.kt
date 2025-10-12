package com.example.floweridentifier.ui.main

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.lifecycle.Lifecycle
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.example.floweridentifier.ui.main.home.HomeFragment
import com.example.floweridentifier.ui.main.myplants.MyPlantsFragment

class MainPagerAdapter(
    fragmentManager: FragmentManager,
    lifecycle: Lifecycle,
) : FragmentStateAdapter(fragmentManager, lifecycle) {

    private val fragmentsCreators: Map<Int, () -> Fragment> = mapOf(
        HOME to { HomeFragment() },
        MY_PLANTS to { MyPlantsFragment() },
    )

    override fun getItemCount() = fragmentsCreators.size

    override fun createFragment(position: Int): Fragment {
        return fragmentsCreators[position]?.invoke() ?: throw IndexOutOfBoundsException()
    }

    companion object {
        private const val HOME = 0
        private const val MY_PLANTS = 1
    }
}