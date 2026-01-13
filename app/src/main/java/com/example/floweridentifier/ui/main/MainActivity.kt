package com.example.floweridentifier.ui.main

import android.app.Activity
import android.content.Intent
import android.graphics.RenderEffect
import android.graphics.Shader
import android.net.Uri
import android.os.Build
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.core.view.GravityCompat
import androidx.lifecycle.lifecycleScope
import com.bumptech.glide.Glide
import com.example.floweridentifier.R
import com.example.floweridentifier.data.repository.ProfileRepository
import com.example.floweridentifier.databinding.ActivityMainBinding
import com.example.floweridentifier.extension.imagePicker
import com.example.floweridentifier.ui.base.BaseActivity
import com.example.floweridentifier.ui.chatbot.ChatActivity
import com.example.floweridentifier.ui.recognition.RecognitionActivity
import com.github.dhaval2404.imagepicker.ImagePicker
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : BaseActivity<ActivityMainBinding>() {
    private val pagerAdapter by lazy(LazyThreadSafetyMode.NONE) {
        MainPagerAdapter(supportFragmentManager, lifecycle)
    }
    
    private val profileRepository = ProfileRepository()

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
        // Check if user is logged in, if not redirect to LoginActivity
        if (!com.example.floweridentifier.utils.PreferenceHelper.isLoggedIn(this)) {
            startActivity(Intent(this, com.example.floweridentifier.ui.auth.LoginActivity::class.java))
            finish()
            return
        }
        
        // Load user profile
        loadUserProfile()
    }

    override fun initListener() {
        binding.imgScan.setOnClickListener {
            this.imagePicker()
        }

        // Open drawer from menu button (left)
        binding.imgMenu.setOnClickListener {
            binding.drawerLayout.openDrawer(GravityCompat.START)
        }

        // Handle drawer item clicks
        binding.navView.setNavigationItemSelectedListener { menuItem ->
            when (menuItem.itemId) {
                R.id.nav_chat -> {
                    startActivity(Intent(this, ChatActivity::class.java))
                }
                R.id.nav_notifications -> {
                    startActivity(Intent(this, com.example.floweridentifier.ui.notification.NotificationActivity::class.java))
                }
                R.id.nav_auth -> {
                    if (com.example.floweridentifier.utils.PreferenceHelper.isLoggedIn(this)) {
                        com.example.floweridentifier.utils.PreferenceHelper.clear(this)
                        Toast.makeText(this, "Logged Out", Toast.LENGTH_SHORT).show()
                        startActivity(Intent(this, com.example.floweridentifier.ui.auth.LoginActivity::class.java))
                        finish()
                    } else {
                        startActivity(Intent(this, com.example.floweridentifier.ui.auth.LoginActivity::class.java))
                    }
                }
            }
            binding.drawerLayout.closeDrawer(GravityCompat.START)
            true
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            binding.imgBg.setRenderEffect(
                RenderEffect.createBlurEffect(
                    100F,
                    100F,
                    Shader.TileMode.MIRROR
                )
            )
        }

        updateAuthMenuItem()
    }

    override fun onResume() {
        super.onResume()
        updateAuthMenuItem()
        // Reload profile in case it was updated
        if (com.example.floweridentifier.utils.PreferenceHelper.isLoggedIn(this)) {
            loadUserProfile()
        }
    }

    private fun updateAuthMenuItem() {
        val authItem = binding.navView.menu.findItem(R.id.nav_auth)
        if (com.example.floweridentifier.utils.PreferenceHelper.isLoggedIn(this)) {
            authItem.title = getString(R.string.logout)
            authItem.setIcon(R.drawable.ic_logout)
        } else {
            authItem.title = getString(R.string.login)
            authItem.setIcon(R.drawable.ic_login)
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
                    putExtra("URI", uri.toString())
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
    
    private fun loadUserProfile() {
        val userId = com.example.floweridentifier.utils.PreferenceHelper.getUserId(this)
        val token = com.example.floweridentifier.utils.PreferenceHelper.getToken(this)
        
        if (userId == null || token == null) {
            android.util.Log.d("MainActivity", "Cannot load profile: userId or token is null")
            return
        }
        
        lifecycleScope.launch(Dispatchers.IO) {
            val result = profileRepository.getProfile(userId, token)
            result.onSuccess { profile ->
                if (profile != null) {
                    android.util.Log.d("MainActivity", "Profile loaded: ${profile.full_name ?: profile.username}, avatar: ${profile.avatar_url}")
                    lifecycleScope.launch(Dispatchers.Main) {
                        updateProfileUI(profile)
                    }
                } else {
                    android.util.Log.d("MainActivity", "Profile is null - profile may not exist in database, creating...")
                    // Profile doesn't exist, try to create it
                    val email = com.example.floweridentifier.utils.PreferenceHelper.getEmail(this@MainActivity)
                    if (email != null) {
                        val createResult = profileRepository.createProfileIfNotExists(userId, email, token)
                        createResult.onSuccess { createdProfile ->
                            if (createdProfile != null) {
                                android.util.Log.d("MainActivity", "Profile created successfully")
                                lifecycleScope.launch(Dispatchers.Main) {
                                    updateProfileUI(createdProfile)
                                }
                            } else {
                                lifecycleScope.launch(Dispatchers.Main) {
                                    updateProfileUIWithEmail(email)
                                }
                            }
                        }.onFailure { exception ->
                            android.util.Log.e("MainActivity", "Failed to create profile: ${exception.message}")
                            lifecycleScope.launch(Dispatchers.Main) {
                                updateProfileUIWithEmail(email)
                            }
                        }
                    } else {
                        lifecycleScope.launch(Dispatchers.Main) {
                            updateProfileUIWithEmail("Guest")
                        }
                    }
                }
            }.onFailure { exception ->
                android.util.Log.e("MainActivity", "Failed to load profile: ${exception.message}", exception)
                // Show email as fallback
                val email = com.example.floweridentifier.utils.PreferenceHelper.getEmail(this@MainActivity)
                lifecycleScope.launch(Dispatchers.Main) {
                    updateProfileUIWithEmail(email ?: "Guest")
                }
            }
        }
    }
    
    private fun updateProfileUI(profile: com.example.floweridentifier.data.remote.ProfileDto) {
        // Get the header view from NavigationView
        val headerView: View? = binding.navView.getHeaderView(0)
        headerView?.let { header ->
            val imgAvatar = header.findViewById<ImageView>(R.id.imgAvatar)
            val tvUserName = header.findViewById<TextView>(R.id.tvUserName)
            
            // Update user name - match web app logic: full_name || username
            val displayName = when {
                !profile.full_name.isNullOrBlank() -> profile.full_name
                !profile.username.isNullOrBlank() -> profile.username
                else -> {
                    // Fallback to email if no name available
                    com.example.floweridentifier.utils.PreferenceHelper.getEmail(this) ?: "Guest"
                }
            }
            tvUserName?.text = displayName
            android.util.Log.d("MainActivity", "Updated profile UI: name=$displayName, avatar=${profile.avatar_url}")
            
            // Update avatar
            profile.avatar_url?.let { avatarUrl ->
                if (avatarUrl.isNotEmpty() && avatarUrl.isNotBlank()) {
                    android.util.Log.d("MainActivity", "Loading avatar from: $avatarUrl")
                    Glide.with(this)
                        .load(avatarUrl)
                        .placeholder(R.drawable.ic_flower)
                        .error(R.drawable.ic_flower)
                        .circleCrop()
                        .into(imgAvatar)
                } else {
                    android.util.Log.d("MainActivity", "Avatar URL is empty, using default")
                    // Reset to default if avatar_url is empty
                    imgAvatar?.setImageResource(R.drawable.ic_flower)
                }
            } ?: run {
                android.util.Log.d("MainActivity", "Avatar URL is null, using default")
                // Reset to default if avatar_url is null
                imgAvatar?.setImageResource(R.drawable.ic_flower)
            }
        }
    }
    
    private fun updateProfileUIWithEmail(email: String) {
        // Get the header view from NavigationView
        val headerView: View? = binding.navView.getHeaderView(0)
        headerView?.let { header ->
            val imgAvatar = header.findViewById<ImageView>(R.id.imgAvatar)
            val tvUserName = header.findViewById<TextView>(R.id.tvUserName)
            
            // Show email or Guest
            tvUserName?.text = if (email != "Guest") email else "Guest"
            imgAvatar?.setImageResource(R.drawable.ic_flower)
        }
    }
    
    private fun resetProfileUI() {
        // Get the header view from NavigationView
        val headerView: View? = binding.navView.getHeaderView(0)
        headerView?.let { header ->
            val imgAvatar = header.findViewById<ImageView>(R.id.imgAvatar)
            val tvUserName = header.findViewById<TextView>(R.id.tvUserName)
            
            // Reset to default
            tvUserName?.text = "Guest"
            imgAvatar?.setImageResource(R.drawable.ic_flower)
        }
    }
}
