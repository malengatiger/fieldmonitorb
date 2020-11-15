package com.boha.fieldmonitor3


import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*


class MainActivity : FlutterActivity() {
    private val channelImage = "com.boha.image.channel"
    private val channelVideo = "com.boha.video.channel"
    private val tag = "\uD83C\uDF38 BadLands"

    private lateinit var imageChannelResult: MethodChannel.Result
    private lateinit var videoChannelResult: MethodChannel.Result

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.d(tag, "\uD83C\uDF38 \uD83C\uDF38 " +
                "configureFlutterEngine done, \uD83D\uDD06 " +
                "we have a way in!! \uD83C\uDF38 \uD83C\uDF38")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelImage)
                .setMethodCallHandler { call: MethodCall?, result: MethodChannel.Result? ->
                    Log.d(tag, "\uD83C\uDF4E setMethodCallHandler for channelImage:  \uD83C\uDF4F TODO: get input parameters")
                    if (result != null) {
                        imageChannelResult = result
                    }
                    startImageCamera()
                }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelVideo)
                .setMethodCallHandler { call: MethodCall?, result: MethodChannel.Result? ->
                    Log.d(tag, "\uD83C\uDF4E setMethodCallHandler for channelVideo: ")
                    if (result != null) {
                        videoChannelResult = result
                    }
                    startVideoCamera()
                }

    }

    private fun logMe() {
        Log.d(tag, "logMe: \uD83C\uDF4F \uD83C\uDF4F \uD83C\uDF4F BigCheeseActivity: we could do some damage here")
    }

    var mediaFile: File? = null
    private fun startImageCamera() {
        Log.d(tag, "startCamera: starting the image camera \uD83C\uDF4F \uD83C\uDF4F \uD83C\uDF4F")
        val cameraIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        mediaFile = try {
            createImageFile()
        } catch (ex: IOException) {
            // Error occurred while creating the File
            null
        }
        // Continue only if the File was successfully created
        Log.d(tag, "\uD83C\uDF4F \uD83C\uDF4F \uD83C\uDF4F startCamera: file: ${mediaFile!!.absolutePath}");
        mediaFile?.also {
            val photoURI: Uri = FileProvider.getUriForFile(
                    this,
                    "com.boha3.fileprovider",
                    it
            )
            cameraIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
            startActivityForResult(cameraIntent, REQUEST_TAKE_PHOTO)
        }
    }

    private fun startVideoCamera() {
        Log.d(tag, "startVideoCamera: starting the video camera \uD83C\uDF4F \uD83C\uDF4F \uD83C\uDF4F")
        val cameraIntent = Intent(MediaStore.ACTION_VIDEO_CAPTURE)
        mediaFile = try {
            createVideoFile()
        } catch (ex: IOException) {
            // Error occurred while creating the File
            null
        }
        // Continue only if the File was successfully created
        Log.d(tag, "\uD83C\uDF4F \uD83C\uDF4F \uD83C\uDF4F startCamera: file: ${mediaFile!!.absolutePath}");
        mediaFile?.also {
            val photoURI: Uri = FileProvider.getUriForFile(
                    this,
                    "com.boha3.fileprovider",
                    it
            )
            cameraIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
            startActivityForResult(cameraIntent, REQUEST_MAKE_VIDEO)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        Log.d(tag, "onActivityResult: returning data \uD83C\uDF4F \uD83C\uDF4F \uD83C\uDF4F")


        if (requestCode == REQUEST_TAKE_PHOTO) {
            if (resultCode == Activity.RESULT_CANCELED) {
                imageChannelResult.error("1", "Image failed", "NOTOK")
                return
            }
            if (resultCode == Activity.RESULT_OK) {
                Log.d(tag, " \uD83C\uDF4E \uD83C\uDF4E REQUEST_TAKE_PHOTO: onActivityResult: " +
                        "file size is : \uD83C\uDF4F ${mediaFile!!.length()} \uD83C\uDF4F")
                imageChannelResult.success(mediaFile!!.absolutePath)
            }

        }
        if (requestCode == REQUEST_MAKE_VIDEO) {
            if (resultCode == Activity.RESULT_CANCELED) {
                videoChannelResult.error("1", "Video cancelled", "NOTOK")
                return
            }
            if (resultCode == Activity.RESULT_OK) {
                Log.d(tag, " \uD83C\uDF4E \uD83C\uDF4E REQUEST_MAKE_VIDEO: onActivityResult: " +
                        "file size is : \uD83C\uDF4F ${mediaFile!!.length()} \uD83C\uDF4F")
                videoChannelResult.success(mediaFile!!.absolutePath)
            }
        }
    }

    lateinit var currentPhotoPath: String

    @Throws(IOException::class)
    fun createImageFile(): File? {
        var mFile: File? = null
        try {
            // Create an image file name
            val timeStamp: String = SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
            val storageDir: File = getExternalFilesDir(Environment.DIRECTORY_PICTURES)!!
            mFile = File.createTempFile(
                    "JPEG_${timeStamp}_", /* prefix */
                    ".jpg", /* suffix */
                    storageDir /* directory */
            ).apply {
                // Save a file: path for use with ACTION_VIEW intents
                currentPhotoPath = absolutePath
            }
        } catch (e: Exception) {
            if (imageChannelResult != null) {
                imageChannelResult.error("1", "Image failed", "NOTOK")
            }
            if (videoChannelResult != null) {
                videoChannelResult.error("1", "Video failed", "NOTOK")
            }
        }
        return mFile
    }

    @Throws(IOException::class)
    fun createVideoFile(): File? {
        // Create an image file name
        var mFile: File? = null
        try {
            val timeStamp: String = SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
            val storageDir: File = getExternalFilesDir(Environment.DIRECTORY_MOVIES)!!
            return File.createTempFile(
                    "MP4_${timeStamp}_", /* prefix */
                    ".mp4", /* suffix */
                    storageDir /* directory */
            ).apply {
                // Save a file: path for use with ACTION_VIEW intents
                currentPhotoPath = absolutePath
            }
        } catch (e: Exception) {
            if (imageChannelResult != null) {
                imageChannelResult.error("1", "Image failed", "NOTOK")
            }
            if (videoChannelResult != null) {
                videoChannelResult.error("1", "Video failed", "NOTOK")
            }
        }
        return mFile
    }

    private val REQUEST_TAKE_PHOTO = 1
    private val REQUEST_MAKE_VIDEO = 2
}
