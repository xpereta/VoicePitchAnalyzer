//
//  AppDelegate.swift
//  Voice Pitch Analyzer
//
//  Created by Carola Nitz on 8/18/17.
//  Copyright © 2017 Carola Nitz. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let themeManager = ThemeManager()
        let timeManager = TimeManager()
        let textManager = TextManager(timeManager: timeManager)
        
        let home = HomeViewController(
            themeManager: themeManager,
            textManager: textManager,
            timeManager: timeManager
        )
        
        window?.rootViewController = home
        window?.makeKeyAndVisible()

        FirebaseApp.configure()
        return true
    }
}

