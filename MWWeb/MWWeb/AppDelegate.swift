//
//  AppDelegate.swift
//  MWWeb
//
//  Copyright © Future Workshops. All rights reserved.
//

import UIKit
import MobileWorkflowCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    weak var eventDelegate: AppDelegateEventDelegate?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

