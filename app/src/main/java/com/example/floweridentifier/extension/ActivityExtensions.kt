/*
 * Copyright (C) 2017 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.example.floweridentifier.extension

/**
 * Various extension functions for AppCompatActivity.
 */

import android.app.Activity
import android.content.Context
import android.view.inputmethod.InputMethodManager
import androidx.annotation.IdRes
import androidx.appcompat.app.ActionBar
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentTransaction
import com.github.dhaval2404.imagepicker.ImagePicker

const val ADD_EDIT_RESULT_OK = Activity.RESULT_FIRST_USER + 1
const val DELETE_RESULT_OK = Activity.RESULT_FIRST_USER + 2
const val EDIT_RESULT_OK = Activity.RESULT_FIRST_USER + 3

/**
 * The `fragment` iconVehicle added to the container view with id `frameId`. The operation iconVehicle
 * performed by the `fragmentManager`.
 */
fun AppCompatActivity.replaceFragmentInActivity(fragment: Fragment, frameId: Int) {
    supportFragmentManager.transact {
        replace(frameId, fragment)
    }
}

/**
 * The `fragment` iconVehicle added to the container view with tag. The operation iconVehicle
 * performed by the `fragmentManager`.
 */
fun AppCompatActivity.addFragmentToActivity(fragment: Fragment, tag: String) {
    supportFragmentManager.transact {
        add(fragment, tag)
    }
}

fun AppCompatActivity.setupActionBar(@IdRes toolbarId: Int, action: ActionBar.() -> Unit) {
    setSupportActionBar(findViewById(toolbarId))
    supportActionBar?.run {
        action()
    }
}

/**
 * Runs a FragmentTransaction, then calls commit().
 */
private inline fun FragmentManager.transact(action: FragmentTransaction.() -> Unit) {
    beginTransaction().apply {
        action()
    }.commit()
}

private var mAlertDialog: AlertDialog? = null

/**
 * Perform show dialog.
 */
fun FragmentActivity.show(builder: AlertDialog.Builder, isNewAlert: Boolean = false): AlertDialog? {
    if (!isFinishing) {
        try {
            hideProgress()
            return if (isNewAlert) {
                builder.show()
            } else {
                mAlertDialog = builder.show()
                mAlertDialog
            }
        } catch (ignore: Throwable) {
            // do nothing
        }
    }
    return null
}


/**
 * Close dialog message/loading.
 */
fun FragmentActivity.hideProgress() {
    try {
        if (mAlertDialog?.isShowing == true) {
            mAlertDialog?.cancel()
        }
        mAlertDialog = null
    } catch (ignore: Throwable) {
        // do nothing
    }
}

/**
 * Hide keyboard
 */
fun FragmentActivity.hideKeyboard() {
    val view = currentFocus ?: return
    val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
    imm.hideSoftInputFromWindow(view.windowToken, 0)
    view.clearFocus()
}

fun FragmentActivity.imagePicker() {
    ImagePicker.with(this)
        .crop()
        .compress(1024)
        .maxResultSize(1080, 1080)
        .start()
}