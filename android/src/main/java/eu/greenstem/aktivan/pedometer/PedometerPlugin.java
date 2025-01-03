package eu.greenstem.aktivan.pedometer;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

import android.os.Build;
import android.util.Log;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import com.getcapacitor.*;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;

@CapacitorPlugin(name = "Pedometer", permissions = {
        @Permission(
                strings = { Manifest.permission.ACTIVITY_RECOGNITION },
                alias = "activity_recognition"
        )
})
public class PedometerPlugin extends Plugin implements SensorEventListener {
    private SensorManager sensorManager;
    private Sensor stepCounter;
    private int initialSteps = -1;
    private int currentSteps = 0;
    private int rawSteps = 0;

    @Override
    public void load() {
        sensorManager = (SensorManager) getContext().getSystemService(Context.SENSOR_SERVICE);
        stepCounter = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER);
    }

    @PluginMethod
    public void isAvailable(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("available", stepCounter != null);
        call.resolve(ret);
    }

    @PluginMethod
    public void start(PluginCall call) {
        if (stepCounter == null) {
            call.reject("Step counter sensor not available on this device");
            return;
        }

        sensorManager.registerListener(this, stepCounter, SensorManager.SENSOR_DELAY_FASTEST);
        call.resolve();
    }

    @PluginMethod
    public void stop(PluginCall call) {
        sensorManager.unregisterListener(this);
        currentSteps = 0;
        rawSteps = 0;
        initialSteps = -1;
        call.resolve();
    }

    @PluginMethod
    public void getStepCount(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("steps", currentSteps);
        ret.put("rawSteps", rawSteps);
        call.resolve(ret);
    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        if (event.sensor.getType() == Sensor.TYPE_STEP_COUNTER) {
            Log.d("PedometerPlugin", "Raw sensor value: " + event.values[0]);
            if (initialSteps == -1) {
                initialSteps = (int) event.values[0];
                Log.d("PedometerPlugin", "Initial steps set to: " + initialSteps);
            }
            currentSteps = (int) event.values[0] - initialSteps;
            rawSteps = (int) event.values[0];
            Log.d("PedometerPlugin", "Current steps calculated: " + currentSteps);

            JSObject data = new JSObject();
            data.put("steps", currentSteps);
            data.put("rawSteps", event.values[0]);
            notifyListeners("stepUpdate", data);
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {
        // Not used
    }

    private static final int ACTIVITY_RECOGNITION_REQUEST_CODE = 100;

//    @PluginMethod
//    // Check if permission is granted
//    public void checkPermission(PluginCall call) {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//            boolean b = ContextCompat.checkSelfPermission(
//                    this.getActivity(),
//                    Manifest.permission.ACTIVITY_RECOGNITION
//            ) == PackageManager.PERMISSION_GRANTED;
//        }
//
//        call.resolve(); // Permission not required for Android 9 and below
//    }
//
//    @PluginMethod
//    // Request permission
//    public void requestPermission(PluginCall call) {
////        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
////            if (ContextCompat.checkSelfPermission(this.getActivity(),
////                    Manifest.permission.ACTIVITY_RECOGNITION)
////                    != PackageManager.PERMISSION_GRANTED) {
////
////
////                ActivityCompat.requestPermissions(this.getActivity(),
////                        new String[]{Manifest.permission.ACTIVITY_RECOGNITION},
////                        ACTIVITY_RECOGNITION_REQUEST_CODE);
////
////            }
////        }
////        call.resolve();
//        if (getPermissionState("activity_recognition") == PermissionState.GRANTED) {
//            call.resolve();
//        } else {
//            requestPermissionForAlias("activity_recognition", call, "requestPermissionCallback");
//        }
//    }

}
