//
//  LoginViewController.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 4/29/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private let textManager: TextManager
    private let appleLoginManager: AppleLoginManager

    init(textManager: TextManager,
         appleLoginManager: AppleLoginManager) {

        self.textManager = textManager
        self.appleLoginManager = appleLoginManager
        super.init(nibName: "LoginViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        appleLoginManager.delegate = self
        appleLoginManager.parentController = self
        setAppearance()
    }

    // MARK: - Public

    @IBAction func didPressDoneButton(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func didPressLoginButton(_ sender: Any) {

        activityIndicator.startAnimating()
        appleLoginManager.requestLogin { [weak self] _ in

            self?.activityIndicator.stopAnimating()
        }
    }

    @IBAction func learnMoreButtonPressed(_ sender: Any) {
        routeToAppleSignUpInformation()
    }

    // MARK: - Private

    private func setAppearance() {

        view.backgroundColor = ColorCache.shared.getBackgroundColor()
        let textColor = ColorCache.shared.getTextColor()
        let buttonColor = ColorCache.shared.getInnerRecordButtonColor()

        doneButton.setTitleColor(buttonColor, for: .normal)
        doneButton.setTitle(textManager.getLocalized(.done), for: .normal)

        learnMoreButton.setTitleColor(buttonColor, for: .normal)
        learnMoreButton.setTitle(textManager.getLocalized(.learnMoreLogin), for: .normal)

        if let infoText = textManager.getLocalized(.login) {
            textView.attributedText = textManager.getAttributed(text: infoText, color: textColor)
        }
    }

    private func routeToAppleSignUpInformation() {

        Log.event(.appleLoginInfo)
        var urlString = "https://developer.apple.com"
        urlString += "/design/human-interface-guidelines"
        urlString += "/sign-in-with-apple/overview/introduction/"
        guard let url = URL(string: urlString) else {
            return
        }

        UIApplication.shared.open(url)
    }
}

// MARK: - AppleLoginManagerDelegate
extension LoginViewController: AppleLoginManagerDelegate {

    func appleLoginManager(didFailWith errorMessage: String) {
        // MARK: - TODO -> Handle properly
    }
}
