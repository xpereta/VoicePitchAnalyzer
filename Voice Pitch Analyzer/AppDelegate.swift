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
        
        FirebaseApp.configure()

        let fireStoreManager = FireStoreManager()
        let themeManager = ThemeManager()
        let timeManager = TimeManager()
        let textManager = TextManager(timeManager: timeManager)
        let resultCalculator = ResultCalculator()
        
        let home = HomeViewController(
            fireStoreManager: fireStoreManager,
            themeManager: themeManager,
            textManager: textManager,
            timeManager: timeManager,
            resultCalculator: resultCalculator)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = home
        window?.makeKeyAndVisible()
        
        return true
    }
}
