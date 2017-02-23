//
//  AppDelegate.swift
//  OKJUX
//
//  Created by German Pereyra on 2/8/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import UIKit
import OHHTTPStubs

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainViewController: UIViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        updateAppSettingsVersion()

        #if DEBUG
            for arg in ProcessInfo.processInfo.arguments {
                if arg.contains("Mock-") {
                    let _ = MockRequestHelper.mockAppByString(arg)
                    break
                }
            }
        #endif

        UserManager.sharedInstance.registerUser(uuid: UserHelper.getUUID()) { (error) in
            if let _ = error {
                //TODO: Show error
            } else {
                //TODO: Present landing
                let pagedSnaps = SnapsPageViewController()
                pagedSnaps.orderedViewControllers = [SnapsViewController(), SnapsViewController(hottest: true)]
                self.mainViewController = pagedSnaps

                self.window = UIWindow(frame: UIScreen.main.bounds)
                let navigationController = UINavigationController(rootViewController: self.mainViewController)
                navigationController.isNavigationBarHidden = true
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            }
        }

        return true
    }

    func updateAppSettingsVersion() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            UserDefaults.standard.setValue(String(format: "%@(%@)", version, buildVersion), forKey: "version_number")
            UserDefaults.standard.synchronize()
        }
    }

}
