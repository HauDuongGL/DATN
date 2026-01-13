package com.example.floweridentifier.ui.auth

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.floweridentifier.data.repository.AuthRepository
import com.example.floweridentifier.databinding.LoginActBinding
import com.example.floweridentifier.utils.PreferenceHelper
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class LoginActivity : AppCompatActivity() {
    private lateinit var binding: LoginActBinding
    private val authRepository = AuthRepository()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = LoginActBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Check if already logged in, navigate to MainActivity
        if (PreferenceHelper.isLoggedIn(this)) {
            startActivity(Intent(this, com.example.floweridentifier.ui.main.MainActivity::class.java))
            finish()
            return
        }

        binding.btnLogin.setOnClickListener {
            val email = binding.etEmail.text.toString().trim()
            val password = binding.etPassword.text.toString().trim()

            if (email.isEmpty() || password.isEmpty()) {
                Toast.makeText(this, "Please enter email and password", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            binding.progressBar.visibility = View.VISIBLE
            binding.btnLogin.isEnabled = false

            CoroutineScope(Dispatchers.IO).launch {
                val result = authRepository.signIn(email, password)
                withContext(Dispatchers.Main) {
                    binding.progressBar.visibility = View.GONE
                    binding.btnLogin.isEnabled = true

                    result.onSuccess { authResponse ->
                        PreferenceHelper.saveAuthToken(
                            this@LoginActivity,
                            authResponse.access_token,
                            authResponse.user.email,
                            authResponse.user.id
                        )
                        Toast.makeText(this@LoginActivity, "Login Successful", Toast.LENGTH_SHORT).show()
                        // Navigate to MainActivity after successful login
                        startActivity(Intent(this@LoginActivity, com.example.floweridentifier.ui.main.MainActivity::class.java))
                        finish()
                    }.onFailure { e ->
                        Toast.makeText(this@LoginActivity, "Login Failed: ${e.message}", Toast.LENGTH_LONG).show()
                    }
                }
            }
        }

        binding.tvRegister.setOnClickListener {
            startActivity(Intent(this, RegisterActivity::class.java))
            finish()
        }
    }
}
