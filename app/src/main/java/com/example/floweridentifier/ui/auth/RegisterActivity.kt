package com.example.floweridentifier.ui.auth

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.floweridentifier.data.repository.AuthRepository
import com.example.floweridentifier.databinding.RegisterActBinding
import com.example.floweridentifier.utils.PreferenceHelper
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class RegisterActivity : AppCompatActivity() {
    private lateinit var binding: RegisterActBinding
    private val authRepository = AuthRepository()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = RegisterActBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.btnRegister.setOnClickListener {
            val email = binding.etEmail.text.toString().trim()
            val password = binding.etPassword.text.toString().trim()

            if (email.isEmpty() || password.isEmpty()) {
                Toast.makeText(this, "Please fill all fields", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            binding.progressBar.visibility = View.VISIBLE
            binding.btnRegister.isEnabled = false

            CoroutineScope(Dispatchers.IO).launch {
                val result = authRepository.signUp(email, password)
                withContext(Dispatchers.Main) {
                    binding.progressBar.visibility = View.GONE
                    binding.btnRegister.isEnabled = true

                    result.onSuccess { authResponse ->
                         // Auto login after register if token present (Supabase returns session on signup if auto-confirm is on)
                         if (authResponse.access_token.isNotEmpty()) {
                             PreferenceHelper.saveAuthToken(
                                 this@RegisterActivity,
                                 authResponse.access_token,
                                 authResponse.user.email,
                                 authResponse.user.id
                             )
                             Toast.makeText(this@RegisterActivity, "Registration Successful", Toast.LENGTH_SHORT).show()
                             // Navigate to MainActivity after successful registration
                             startActivity(Intent(this@RegisterActivity, com.example.floweridentifier.ui.main.MainActivity::class.java))
                             finish()
                         } else {
                             Toast.makeText(this@RegisterActivity, "Registration Successful. Please check email to confirm.", Toast.LENGTH_LONG).show()
                             startActivity(Intent(this@RegisterActivity, LoginActivity::class.java))
                             finish()
                         }
                    }.onFailure { e ->
                        Toast.makeText(this@RegisterActivity, "Registration Failed: ${e.message}", Toast.LENGTH_LONG).show()
                    }
                }
            }
        }

        binding.tvLogin.setOnClickListener {
            startActivity(Intent(this, LoginActivity::class.java))
            finish()
        }
    }
}
