//package com.dinmajurplatformservice.dinmajurcustomer
//
//import io.flutter.embedding.android.FlutterActivity
//
//class MainActivity : FlutterActivity()
package com.dinmajurplatformservice.dinmajurcustomer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.webviewflutter.WebViewFlutterPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Manually register WebView plugin
        flutterEngine.plugins.add(WebViewFlutterPlugin())
    }
}