//
//  ResultViewController.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import UIKit
import XYColor

class ResultViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var rangeContainer: UIView!
    @IBOutlet weak var femaleLabel: UILabel!
    @IBOutlet weak var androLabel: UILabel!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var maleRangeLabel: UILabel!
    @IBOutlet weak var femaleRangeLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var lastLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let fireStoreManager: FireStoreManager
    private let themeManager: ThemeManager
    private let resultCalculator: ResultCalculator
    private let pitchArray: Array<Double>
    
    private var results = [RecorderResult]()
        
    private lazy var dateFormatter: DateFormatter = {
        return DateFormatter()
    }()
    
    init(fireStoreManager: FireStoreManager,
         themeManager: ThemeManager,
         resultCalculator: ResultCalculator,
         pitchArray: Array<Double>) {
        
        self.fireStoreManager = fireStoreManager
        self.themeManager = themeManager
        self.resultCalculator = resultCalculator
        self.pitchArray = pitchArray
        super.init(nibName: "ResultViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            UINib.init(nibName: "ResultCell", bundle: nil),
            forCellReuseIdentifier: "ResultCell")
        
        setAppearance()
        
        getLastResults { [weak self] results in
            
            DispatchQueue.main.async { [weak self] in
                
                self?.results = results.reversed()
                self?.tableView.reloadData()
                
                self?.setCurrentResult()
                self?.setLastResult(results.last)
            }
        }
    }
    
    @IBAction func didPressDoneButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Private
    
    private func setAppearance() {
        
        activityIndicator.hidesWhenStopped = true
        view.backgroundColor = themeManager.getBackgroundColor()
        let buttonColor = themeManager.getInnerRecordButtonColor()
        let waveformColor = themeManager.getWaveformColor()
        let bordercolor = themeManager.getBorderColor()
        
        doneButton.setTitleColor(buttonColor, for: .normal)
        
        femaleLabel.textColor = themeManager.getTimeTextColor()
        androLabel.textColor = themeManager.getTimeTextColor()
        maleLabel.textColor = themeManager.getTimeTextColor()
        currentLabel.textColor = themeManager.getTimeTextColor()
        lastLabel.textColor = themeManager.getTimeTextColor()
        
        maleRangeLabel.textColor = themeManager.getSubTextColor()
        femaleRangeLabel.textColor = themeManager.getSubTextColor()
        
        rangeContainer.backgroundColor = waveformColor
        rangeContainer.layer.cornerRadius = 16
        
        rangeContainer.setLayerBorderColor(bordercolor)
        rangeContainer.layer.setBorderColor(bordercolor, with: rangeContainer)
        rangeContainer.layer.borderWidth = 1
    }
    
    private func storeResult(min minAverage: Double, max maxAverage: Double) {
        
        guard let identifierForVendor = UIDevice.current.identifierForVendor,
            minAverage > 0,
            maxAverage > 0 else {
                return
        }
        
        let result = RecorderResult(
            minAverage: minAverage,
            maxAverage: maxAverage,
            userID: identifierForVendor.uuidString)
        
        fireStoreManager.setLastResult(result)
    }
    
    private func getLastResults(completion: @escaping ([RecorderResult]) -> ()) {
        
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            completion([])
            return
        }
        
        activityIndicator.startAnimating()
        let uuid = identifierForVendor.uuidString
        fireStoreManager.getLastResults(userID: uuid) { [weak self] results in
            
            self?.activityIndicator.stopAnimating()
            completion(results)
        }
    }
    
    private func setLastResult(_ result: RecorderResult?) {
        
        guard let result = result else {
            return
        }
        
        let layer = themeManager.getLastResultLayer(
            min: result.minAverage,
            max: result.maxAverage,
            on: rangeContainer)
        
        rangeContainer.layer.addSublayer(layer)
    }
    
    private func setCurrentResult() {
        
        let maxAverage = resultCalculator.getAverage(of: pitchArray, getMax: true)
        let minAverage = resultCalculator.getAverage(of: pitchArray, getMax: false)
        
        print("maxAverage: \(maxAverage)")
        print("minAverage: \(minAverage)")
        
        storeResult(min: minAverage, max: maxAverage)
        
        let layer = themeManager.getCurrentResultLayer(
            min: minAverage,
            max: maxAverage,
            on: rangeContainer)
        
        rangeContainer.layer.addSublayer(layer)
    }
}

extension ResultViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let result = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        
        let content = ResultCellContent(
            result: result,
            themeManager: themeManager,
            dateFormatter: dateFormatter)
        
        cell.bindViewModel(content)
        return cell
    }
}
