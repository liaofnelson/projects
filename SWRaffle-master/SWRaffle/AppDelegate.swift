//
//  AppDelegate.swift
//  SWRaffle
//
//  Created by Jason on 2020/4/16.
//  Copyright © 2020 UTAS. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().tintColor = UIColor.orange;

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController.init(rootViewController: SWHomeViewController.init(style: .grouped))
        window?.makeKeyAndVisible()
        
        return true
    }
}

