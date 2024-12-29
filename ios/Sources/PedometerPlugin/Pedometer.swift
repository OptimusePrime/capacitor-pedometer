import Foundation

@objc public class Pedometer: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
