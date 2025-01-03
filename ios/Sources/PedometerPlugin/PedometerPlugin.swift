import Foundation
import Capacitor
import CoreMotion

@objc(PedometerPlugin)
public class PedometerPlugin: CAPPlugin {
    private let pedometer = CMPedometer()
    private var initialSteps: Int = 0
    private var isTracking: Bool = false

    @objc func isAvailable(_ call: CAPPluginCall) {
        call.resolve([
            "available": CMPedometer.isStepCountingAvailable()
        ])
    }

    @objc func start(_ call: CAPPluginCall) {
        guard CMPedometer.isStepCountingAvailable() else {
            call.reject("Pedometer is not available on this device")
            return
        }

        // Reset initial steps when starting
        initialSteps = 0
        isTracking = true

        // Get initial step count
        let now = Date()
        pedometer.queryPedometerData(from: now.addingTimeInterval(-1), to: now) { (data, error) in
            if let data = data {
                self.initialSteps = data.numberOfSteps.intValue
            }

            // Start updates after getting initial count
            self.pedometer.startUpdates(from: Date()) { (data, error) in
                if let error = error {
                    self.notifyListeners("pedometerError", data: [
                        "message": error.localizedDescription
                    ])
                    return
                }

                if let data = data, self.isTracking {
                    let currentSteps = data.numberOfSteps.intValue
                    let stepsSinceStart = currentSteps - self.initialSteps

                    self.notifyListeners("stepUpdate", data: [
                        "steps": stepsSinceStart,
                        "rawSteps": currentSteps,
                        "timestamp": ISO8601DateFormatter().string(from: data.startDate)
                    ])
                }
            }
        }

        call.resolve()
    }

    @objc func stop(_ call: CAPPluginCall) {
        pedometer.stopUpdates()
        isTracking = false
        initialSteps = 0
        call.resolve()
    }

    @objc func getStepCount(_ call: CAPPluginCall) {
        guard CMPedometer.isStepCountingAvailable() else {
            call.reject("Pedometer is not available on this device")
            return
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        pedometer.queryPedometerData(from: startOfDay, to: now) { (data, error) in
            if let error = error {
                call.reject("Error getting step count: \(error.localizedDescription)")
                return
            }

            if let data = data {
                let currentSteps = data.numberOfSteps.intValue
                let stepsSinceStart = self.isTracking ? (currentSteps - self.initialSteps) : currentSteps

                call.resolve([
                    "steps": stepsSinceStart,
                    "rawSteps": currentSteps
                ])
            }
        }
    }

    @objc func checkPermissions(_ call: CAPPluginCall) {
        if #available(iOS 11.0, *) {
            switch CMMotionActivityManager.authorizationStatus() {
            case .authorized:
                call.resolve(["state": "granted"])
            case .denied:
                call.resolve(["state": "denied"])
            case .restricted:
                call.resolve(["state": "denied"])
            case .notDetermined:
                call.resolve(["state": "prompt"])
            @unknown default:
                call.resolve(["state": "prompt"])
            }
        } else {
            // For iOS versions < 11.0, we can't check authorization status
            // We'll have to attempt to request and see what happens
            call.resolve(["state": "prompt"])
        }
    }

    @objc func requestPermissions(_ call: CAPPluginCall) {
        if #available(iOS 11.0, *) {
            // Check current status first
            switch CMMotionActivityManager.authorizationStatus() {
            case .authorized:
                call.resolve(["state": "granted"])
                return
            case .denied, .restricted:
                call.reject("Permissions denied")
                return
            case .notDetermined:
                break // Continue with request
            @unknown default:
                break // Continue with request
            }
        }

        // Create a motion activity manager to trigger the permission prompt
        let activityManager = CMMotionActivityManager()
        let today = Date()

        activityManager.queryActivityStarting(from: today, to: today, to: OperationQueue.main) { (activities, error) in
            // The callback will be called after user responds to permission prompt
            if CMMotionActivityManager.authorizationStatus() == .authorized {
                call.resolve(["state": "granted"])
            } else {
                call.reject("Permissions denied")
            }
            activityManager.stopActivityUpdates()
        }
    }
}
