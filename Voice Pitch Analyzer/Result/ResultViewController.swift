//
//  ResultViewController.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    
    private let fireStoreManager: FireStoreManager
    private let resultCalculator: ResultCalculator
    private let pitchArray: Array<Double>
    
    init(fireStoreManager: FireStoreManager,
         resultCalculator: ResultCalculator,
         pitchArray: Array<Double>) {
        
        self.fireStoreManager = fireStoreManager
        self.resultCalculator = resultCalculator
        self.pitchArray = pitchArray
        super.init(nibName: "ResultViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("pitchArray: \(pitchArray)")
        
        let minAverage = resultCalculator.getAverage(of: pitchArray, getMax: false)
        let maxAverage = resultCalculator.getAverage(of: pitchArray, getMax: true)
        storeLastResult(min: minAverage, max: maxAverage)
        
        print("maxAverage: \(maxAverage)")
        print("minAverage: \(minAverage)")
        
        let rangeView = RangeView(min:minAverage, max:maxAverage)

        rangeView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(rangeView)

        let constraints = [
            rangeView.leftAnchor.constraint(equalTo: view.leftAnchor),
            rangeView.rightAnchor.constraint(equalTo: view.rightAnchor),
            rangeView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor),
            rangeView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Private
    
    private func storeLastResult(min minAverage: Double, max maxAverage: Double) {
        
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }
        
        let uuid = identifierForVendor.uuidString
        fireStoreManager.setLastResult(userID: uuid, min: minAverage, max: maxAverage)
    }
    
    private func getLastResults() {
        
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }
        
        let uuid = identifierForVendor.uuidString
        fireStoreManager.getLastResult(userID: uuid) { result in
            print("last result: \(result)")
        }
    }
}
