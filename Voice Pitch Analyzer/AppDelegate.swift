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
        Log.event(.appStart)

        let recordingManager = RecordingManager()
        let databaseManager = DatabaseManager()
        databaseManager.configure()
        
        let themeManager = ThemeManager()
        let textManager = TextManager()
        let resultCalculator = ResultCalculator()
        
        let home = HomeViewController(
            recordingManager: recordingManager,
            databaseManager: databaseManager,
            themeManager: themeManager,
            textManager: textManager,
            resultCalculator: resultCalculator)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = home
        window?.makeKeyAndVisible()
        
        return true
    }
}
