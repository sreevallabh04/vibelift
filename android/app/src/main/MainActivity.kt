import android.content.pm.PackageManager
import android.content.pm.PackageInfo
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "vibelift/health").setMethodCallHandler {
            call, result ->
            if (call.method == "getSamsungHealthStatus") {
                val packageName = "com.sec.android.app.shealth"
                val response = HashMap<String, Any>()
                try {
                    val pm = applicationContext.packageManager
                    val pi = pm.getPackageInfo(packageName, 0)
                    response["installed"] = true
                    response["enabled"] = pm.getApplicationEnabledSetting(packageName) == PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                    response["version"] = pi.versionCode
                } catch (e: PackageManager.NameNotFoundException) {
                    response["installed"] = false
                    response["enabled"] = false
                    response["version"] = 0
                }
                result.success(response)
            } else {
                result.notImplemented()
            }
        }
    }
}
