package com.example.edumanage_offline

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class MainActivity : FlutterActivity() {
    private val channelName = "com.edumanage/license_storage"
    private val preferencesName = "edumanage_license_secure_values"
    private val keyAlias = "edumanage_license_storage_v1"
    private val transformation = "AES/GCM/NoPadding"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                try {
                    val key = call.argument<String>("key")
                    if (key.isNullOrBlank()) {
                        result.error("INVALID_KEY", "A storage key is required.", null)
                        return@setMethodCallHandler
                    }
                    when (call.method) {
                        "read" -> result.success(readValue(key))
                        "write" -> {
                            val value = call.argument<String>("value")
                            if (value == null) {
                                result.error("INVALID_VALUE", "A storage value is required.", null)
                            } else {
                                writeValue(key, value)
                                result.success(null)
                            }
                        }
                        "delete" -> {
                            getSharedPreferences(preferencesName, MODE_PRIVATE)
                                .edit().remove(key).apply()
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("SECURE_STORAGE_ERROR",
                        "Secure license storage operation failed.", error.javaClass.simpleName)
                }
            }
    }

    private fun readValue(preferenceKey: String): String? {
        val encoded = getSharedPreferences(preferencesName, MODE_PRIVATE)
            .getString(preferenceKey, null) ?: return null
        val packed = Base64.decode(encoded, Base64.NO_WRAP)
        require(packed.size > 12) { "Invalid encrypted value." }
        val iv = packed.copyOfRange(0, 12)
        val ciphertext = packed.copyOfRange(12, packed.size)
        val cipher = Cipher.getInstance(transformation)
        cipher.init(Cipher.DECRYPT_MODE, getOrCreateKey(), GCMParameterSpec(128, iv))
        return String(cipher.doFinal(ciphertext), Charsets.UTF_8)
    }

    private fun writeValue(preferenceKey: String, value: String) {
        val cipher = Cipher.getInstance(transformation)
        cipher.init(Cipher.ENCRYPT_MODE, getOrCreateKey())
        val encrypted = cipher.doFinal(value.toByteArray(Charsets.UTF_8))
        val packed = cipher.iv + encrypted
        getSharedPreferences(preferencesName, MODE_PRIVATE).edit()
            .putString(preferenceKey, Base64.encodeToString(packed, Base64.NO_WRAP))
            .apply()
    }

    private fun getOrCreateKey(): SecretKey {
        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        val existing = keyStore.getKey(keyAlias, null) as? SecretKey
        if (existing != null) return existing
        val generator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
        generator.init(KeyGenParameterSpec.Builder(
            keyAlias,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        ).setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setRandomizedEncryptionRequired(true)
            .build())
        return generator.generateKey()
    }
}
