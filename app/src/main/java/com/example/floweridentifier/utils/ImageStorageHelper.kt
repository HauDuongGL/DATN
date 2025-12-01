package com.example.floweridentifier.utils

import android.content.Context
import android.util.Log
import com.example.floweridentifier.data.model.FlowerImage
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

/**
 * Helper class để quản lý việc lưu trữ hình ảnh local
 * Hình ảnh được lưu trong internal storage của app
 */
object ImageStorageHelper {
    private const val TAG = "ImageStorageHelper"
    private const val IMAGES_DIR = "flower_images"

    /**
     * Lấy thư mục lưu trữ hình ảnh
     */
    private fun getImagesDirectory(context: Context): File {
        val dir = File(context.filesDir, IMAGES_DIR)
        if (!dir.exists()) {
            dir.mkdirs()
        }
        return dir
    }

    /**
     * Lấy thư mục cho một loài hoa cụ thể
     */
    private fun getFlowerDirectory(context: Context, flowerName: String): File {
        val dir = File(getImagesDirectory(context), flowerName)
        if (!dir.exists()) {
            dir.mkdirs()
        }
        return dir
    }

    /**
     * Copy hình ảnh từ assets vào internal storage
     * @param context Application context
     * @param assetPath Đường dẫn trong assets (vd: "flowers/rose/image1.jpg")
     * @param flowerName Tên loài hoa
     * @param fileName Tên file đích
     * @return Đường dẫn file đã copy, hoặc null nếu thất bại
     */
    fun copyImageFromAssets(
        context: Context,
        assetPath: String,
        flowerName: String,
        fileName: String
    ): String? {
        return try {
            val flowerDir = getFlowerDirectory(context, flowerName)
            val destFile = File(flowerDir, fileName)

            // Nếu file đã tồn tại, không copy lại
            if (destFile.exists()) {
                return destFile.absolutePath
            }

            context.assets.open(assetPath).use { input ->
                FileOutputStream(destFile).use { output ->
                    input.copyTo(output)
                }
            }

            Log.d(TAG, "Copied image from assets: $assetPath -> ${destFile.absolutePath}")
            destFile.absolutePath
        } catch (e: IOException) {
            Log.e(TAG, "Failed to copy image from assets: $assetPath", e)
            null
        }
    }

    /**
     * Lưu hình ảnh từ byte array vào internal storage
     * @param context Application context
     * @param imageData Dữ liệu hình ảnh
     * @param flowerName Tên loài hoa
     * @param fileName Tên file
     * @return Đường dẫn file đã lưu, hoặc null nếu thất bại
     */
    fun saveImageToStorage(
        context: Context,
        imageData: ByteArray,
        flowerName: String,
        fileName: String
    ): String? {
        return try {
            val flowerDir = getFlowerDirectory(context, flowerName)
            val destFile = File(flowerDir, fileName)

            FileOutputStream(destFile).use { output ->
                output.write(imageData)
            }

            Log.d(TAG, "Saved image to storage: ${destFile.absolutePath}")
            destFile.absolutePath
        } catch (e: IOException) {
            Log.e(TAG, "Failed to save image to storage", e)
            null
        }
    }

    /**
     * Copy file hình ảnh vào internal storage
     * @param context Application context
     * @param sourceFile File nguồn
     * @param flowerName Tên loài hoa
     * @param fileName Tên file đích
     * @return Đường dẫn file đã copy, hoặc null nếu thất bại
     */
    fun copyImageFile(
        context: Context,
        sourceFile: File,
        flowerName: String,
        fileName: String
    ): String? {
        return try {
            val flowerDir = getFlowerDirectory(context, flowerName)
            val destFile = File(flowerDir, fileName)

            sourceFile.inputStream().use { input ->
                FileOutputStream(destFile).use { output ->
                    input.copyTo(output)
                }
            }

            Log.d(TAG, "Copied image file: ${sourceFile.absolutePath} -> ${destFile.absolutePath}")
            destFile.absolutePath
        } catch (e: IOException) {
            Log.e(TAG, "Failed to copy image file", e)
            null
        }
    }

    /**
     * Xóa hình ảnh khỏi storage
     * @param imagePath Đường dẫn hình ảnh cần xóa
     * @return true nếu xóa thành công
     */
    fun deleteImage(imagePath: String): Boolean {
        return try {
            val file = File(imagePath)
            val deleted = file.delete()
            if (deleted) {
                Log.d(TAG, "Deleted image: $imagePath")
            }
            deleted
        } catch (e: Exception) {
            Log.e(TAG, "Failed to delete image: $imagePath", e)
            false
        }
    }

    /**
     * Khởi tạo hình ảnh từ assets cho một loài hoa
     * Copy tất cả hình ảnh từ assets/flowers/[flowerName]/ vào internal storage
     * @param context Application context
     * @param flowerName Tên loài hoa
     * @return Danh sách FlowerImage đã được tạo
     */
    fun initializeFlowerImages(context: Context, flowerName: String): List<FlowerImage> {
        val images = mutableListOf<FlowerImage>()
        val assetPath = "flowers/$flowerName"

        try {
            // List tất cả file trong thư mục assets
            val fileList = context.assets.list(assetPath) ?: emptyArray()

            fileList.filter { it.endsWith(".jpg") || it.endsWith(".jpeg") || it.endsWith(".png") }
                .forEach { fileName ->
                    val fullAssetPath = "$assetPath/$fileName"
                    val localPath = copyImageFromAssets(context, fullAssetPath, flowerName, fileName)

                    if (localPath != null) {
                        images.add(
                            FlowerImage(
                                flowerName = flowerName,
                                imageUrl = localPath
                            )
                        )
                    }
                }

            Log.d(TAG, "Initialized ${images.size} images for $flowerName")
        } catch (e: IOException) {
            Log.e(TAG, "Failed to initialize images for $flowerName", e)
        }

        return images
    }

    /**
     * Kiểm tra xem file hình ảnh có tồn tại không
     */
    fun imageExists(imagePath: String): Boolean {
        return File(imagePath).exists()
    }

    /**
     * Lấy tất cả hình ảnh của một loài hoa từ storage
     * @param context Application context
     * @param flowerName Tên loài hoa
     * @return Danh sách đường dẫn hình ảnh
     */
    fun getFlowerImagesFromStorage(context: Context, flowerName: String): List<String> {
        val flowerDir = getFlowerDirectory(context, flowerName)
        return flowerDir.listFiles()
            ?.filter { it.isFile && (it.extension == "jpg" || it.extension == "jpeg" || it.extension == "png") }
            ?.map { it.absolutePath }
            ?: emptyList()
    }
}
