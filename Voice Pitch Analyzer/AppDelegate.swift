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

    private let microphoneAccessManager = MicrophoneAccessManager()
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        Log.event(.appStart)

        let recordingManager = RecordingManager()
        let authManager = AuthManager()
        let databaseManager = DatabaseManager(authManager: authManager)
        databaseManager.configure()

        let themeManager = ThemeManager()
        let textManager = TextManager()
        let resultCalculator = ResultCalculator()
        let cloudFunctionsManager = CloudFunctionsManager()

        let appleLoginManager = AppleLoginManager(
            cloudFunctionsManager: cloudFunctionsManager,
            authManager: authManager
        )

        let home = HomeViewController(
            recordingManager: recordingManager,
            databaseManager: databaseManager,
            themeManager: themeManager,
            textManager: textManager,
            resultCalculator: resultCalculator,
            microphoneAccessManager: microphoneAccessManager,
            appleLoginManager: appleLoginManager
        )

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = home
        window?.makeKeyAndVisible()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        microphoneAccessManager.checkAuthorizationStatus()
    }
}
