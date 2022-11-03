//
//  AppDelegate.swift
//  Runner
//
//  Created by Andrew on 2022/07/30.
//  ydm2790@gmail.com
//

import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  private var device = UIDevice.current

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "flutter.native.dev/info",
                                                 binaryMessenger: controller.binaryMessenger)
        methodChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // This method is invoked on the UI thread.
            switch call.method {
            case "getBatteryLevel":
                self?.receiveBatteryLevel(result: result)
            case "getDeviceInfo":
                self?.receiveDeviceInfo(result: result)
            case "getPackageInfo":
                self?.receivePackageInfoData(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

    func receivePackageInfoData(result: FlutterResult) {
        result([
            "appName": Bundle.main.object(
                forInfoDictionaryKey: "CFBundleDisplayName") ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? NSNull(),
            "packageName": Bundle.main.bundleIdentifier ?? NSNull(),
            "version": Bundle.main.object(
                forInfoDictionaryKey: "CFBundleShortVersionString") ?? NSNull(),
            "buildNumber": Bundle.main.object(
                forInfoDictionaryKey: "CFBundleVersion") ?? NSNull()
        ])
    }

    func receiveBatteryLevel(result: FlutterResult) {
        device.isBatteryMonitoringEnabled = true
        if device.batteryState == UIDevice.BatteryState.unknown {
            result(FlutterError(code: "UNAVAILABLE",
                                message: "Battery level not available.",
                                details: nil))
        } else {
            result(Int(device.batteryLevel * 100))
        }
    }

    func receiveDeviceInfo(result: FlutterResult) {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafeMutablePointer(to: &systemInfo.machine) {
            ptr in String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
        let model = getName(modelCode: modelCode)
        let build: [String: Any] = [
            "name": device.name,
            "model": model,
            "deviceName": device.name,
            "systemName": device.systemName,
            "systemVersion": device.systemVersion,
            "localizedModel": device.localizedModel,
            "identifierForVendor": device.identifierForVendor!.uuidString,
            // "utsname": systemInfo,
        ]
        result(build)
    }

    func getName (modelCode: String) -> String {
        switch modelCode {
        case "i386": return "iPhone Simulator"
        case "x86_64": return "iPhone Simulator"
        case "arm64": return "iPhone Simulator"
        case "iPhone1,1": return "iPhone"
        case "iPhone1,2": return "iPhone 3"
        case "iPhone2,1": return "iPhone 3G"
        case "iPhone3,1": return "iPhone 4"
        case "iPhone3,2": return "iPhone 4 GSM Rev A"
        case "iPhone3,3": return "iPhone 4 CDMA"
        case "iPhone4,1": return "iPhone 4"
        case "iPhone5,1": return "iPhone 5 (GSM)"
        case "iPhone5,2": return "iPhone 5 (GSM+CDMax)"
        case "iPhone5,3": return "iPhone 5C (GSM)"
        case "iPhone5,4": return "iPhone 5C (Global)"
        case "iPhone6,1": return "iPhone 5S (GSM)"
        case "iPhone6,2": return "iPhone 5S (Global)"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone8,1": return "iPhone 6"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone8,4": return "iPhone SE (GSM)"
        case "iPhone9,1": return "iPhone 7"
        case "iPhone9,2": return "iPhone 7 Plus"
        case "iPhone9,3": return "iPhone 7"
        case "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone10,1": return "iPhone 8"
        case "iPhone10,2": return "iPhone 8 Plus"
        case "iPhone10,3": return "iPhone X Global"
        case "iPhone10,4": return "iPhone X"
        case "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,6": return "iPhone X GSM"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4": return "iPhone XS Plus"
        case "iPhone11,6": return "iPhone XS Max Global"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPhone12,8": return "iPhone SE 2nd Ge"
        case "iPhone13,1": return "iPhone 12 Mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,4": return "iPhone 13 Mini"
        case "iPhone14,5": return "iPhone 13"
        case "iPhone14,6": return "iPhone SE 3rd Gen"
        default: return modelCode;
        }
    }
}
}
