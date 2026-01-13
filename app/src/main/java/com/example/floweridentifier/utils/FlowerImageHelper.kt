package com.example.floweridentifier.utils

import android.content.Context
import android.util.Log
import java.io.File
import java.io.InputStream

/**
 * Helper class để load ảnh hoa từ thư mục Img_flower dựa trên tên hoa nhận diện
 */
object FlowerImageHelper {
    private const val TAG = "FlowerImageHelper"
    
    /**
     * Map tên hoa từ API response sang tên file ảnh trong thư mục Img_flower
     * Ví dụ: "sunflower" -> "Sunflower.jpg", "black_eyed_susan" -> "Black eyed susan.jpg"
     */
    fun getFlowerImageFileName(flowerName: String): String {
        // Chuyển đổi tên hoa sang format phù hợp với tên file
        val formattedName = when (flowerName.lowercase()) {
            "black_eyed_susan" -> "Black eyed susan"
            "california_poppy" -> "California Poppy"
            "forget-me-not", "forget_me_not" -> "Forget-Me-Not"
            "water_lily", "waterlily" -> "Water Lily"
            "common_daisy" -> "Common Daisy"
            "cherryblossom" -> "Cherryblossom"
            "lilyvalley" -> "Lilyvalley"
            "tigerlily" -> "Tigerlily"
            else -> {
                // Chuyển đổi snake_case hoặc lowercase sang Title Case
                flowerName.split("_", " ")
                    .joinToString(" ") { word ->
                        word.lowercase().replaceFirstChar { 
                            if (it.isLowerCase()) it.titlecase(java.util.Locale.ROOT) 
                            else it.toString() 
                        }
                    }
            }
        }
        return "$formattedName.jpg"
    }
    
    /**
     * Lấy đường dẫn file ảnh từ thư mục Img_flower trong assets
     * @param context Application context
     * @param flowerName Tên hoa từ API response
     * @return Đường dẫn file trong assets hoặc null nếu không tìm thấy
     */
    fun getFlowerImageAssetPath(context: Context, flowerName: String): String? {
        val fileName = getFlowerImageFileName(flowerName)
        val assetPath = "flowers/$fileName"
        
        return try {
            // Kiểm tra xem file có tồn tại trong assets không
            context.assets.open(assetPath).use {
                Log.d(TAG, "Found image at: $assetPath")
                assetPath
            }
        } catch (e: Exception) {
            Log.w(TAG, "Image not found in assets: $assetPath, trying alternative paths")
            // Thử các đường dẫn khác
            tryAlternativePaths(context, flowerName, fileName)
        }
    }
    
    /**
     * Thử các đường dẫn thay thế để tìm ảnh
     */
    private fun tryAlternativePaths(context: Context, flowerName: String, fileName: String): String? {
        // Thử với các biến thể khác nhau của tên file
        val alternatives = listOf(
            "flowers/$fileName", // Đã thử ở trên, nhưng thử lại với format khác
            "flowers/${flowerName.replace("_", " ").split(" ").joinToString(" ") { it.lowercase().replaceFirstChar { char -> 
                if (char.isLowerCase()) char.titlecase(java.util.Locale.ROOT) else char.toString() 
            }}.replace(" ", "")}.jpg",
            "flowers/${flowerName.lowercase().replace("_", " ").split(" ").joinToString(" ") { it.replaceFirstChar { char -> 
                if (char.isLowerCase()) char.titlecase(java.util.Locale.ROOT) else char.toString() 
            }}.replace(" ", "")}.jpg",
            "flowers/${flowerName.lowercase()}.jpg",
            "flowers/${flowerName.replace("_", "-").lowercase()}.jpg"
        )
        
        alternatives.forEach { path ->
            try {
                context.assets.open(path).use {
                    Log.d(TAG, "Found image at alternative path: $path")
                    return path
                }
            } catch (e: Exception) {
                // Continue trying
            }
        }
        
        // Thử list tất cả các file trong thư mục flowers và tìm file phù hợp
        try {
            val files = context.assets.list("flowers") ?: emptyArray()
            val matchingFile = files.firstOrNull { file ->
                val fileLower = file.lowercase().replace(" ", "").replace("-", "").replace("_", "")
                val flowerLower = flowerName.lowercase().replace(" ", "").replace("-", "").replace("_", "")
                fileLower.contains(flowerLower) || flowerLower.contains(fileLower.replace(".jpg", ""))
            }
            
            if (matchingFile != null) {
                val foundPath = "flowers/$matchingFile"
                Log.d(TAG, "Found matching image: $foundPath")
                return foundPath
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error listing assets files", e)
        }
        
        Log.e(TAG, "Could not find image for flower: $flowerName")
        return null
    }
    
    /**
     * Lấy đường dẫn file ảnh từ internal storage (nếu đã được copy từ assets)
     * @param context Application context
     * @param flowerName Tên hoa từ API response
     * @return Đường dẫn file trong internal storage hoặc null nếu không tìm thấy
     */
    fun getFlowerImageFromStorage(context: Context, flowerName: String): String? {
        val fileName = getFlowerImageFileName(flowerName)
        val storageDir = File(context.filesDir, "flower_images")
        val flowerDir = File(storageDir, flowerName.lowercase())
        val imageFile = File(flowerDir, fileName)
        
        return if (imageFile.exists()) {
            imageFile.absolutePath
        } else {
            // Thử tìm với tên file khác
            flowerDir.listFiles()?.firstOrNull()?.absolutePath
        }
    }
    
    /**
     * Load ảnh từ assets và copy vào internal storage nếu cần
     * @param context Application context
     * @param flowerName Tên hoa từ API response
     * @return Đường dẫn file trong internal storage hoặc null nếu không tìm thấy
     */
    fun loadFlowerImageToStorage(context: Context, flowerName: String): String? {
        val assetPath = getFlowerImageAssetPath(context, flowerName) ?: return null
        val fileName = getFlowerImageFileName(flowerName)
        
        return try {
            ImageStorageHelper.copyImageFromAssets(
                context,
                assetPath,
                flowerName.lowercase(),
                fileName
            )
        } catch (e: Exception) {
            Log.e(TAG, "Failed to copy image to storage: $flowerName", e)
            null
        }
    }
    
    /**
     * Lấy InputStream từ assets để Glide có thể load
     * @param context Application context
     * @param flowerName Tên hoa từ API response
     * @return InputStream hoặc null nếu không tìm thấy
     */
    fun getFlowerImageInputStream(context: Context, flowerName: String): InputStream? {
        val assetPath = getFlowerImageAssetPath(context, flowerName) ?: return null
        return try {
            context.assets.open(assetPath)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open asset stream: $assetPath", e)
            null
        }
    }
    
    /**
     * Tạo URI từ assets để Glide có thể load
     * Glide có thể load từ assets bằng cách sử dụng "file:///android_asset/..."
     * @param context Application context
     * @param flowerName Tên hoa từ API response
     * @return URI string hoặc null nếu không tìm thấy
     */
    fun getFlowerImageUri(context: Context, flowerName: String): String? {
        val assetPath = getFlowerImageAssetPath(context, flowerName) ?: return null
        return "file:///android_asset/$assetPath"
    }
}
