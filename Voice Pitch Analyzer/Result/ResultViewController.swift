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
    
    private let databaseManager: DatabaseManager
    private let themeManager: ThemeManager
    private let resultCalculator: ResultCalculator
    private let pitchArray: Array<Double>
    
    private var results = [RecorderResult]()
        
    private lazy var dateFormatter: DateFormatter = {
        return DateFormatter()
    }()
    
    init(databaseManager: DatabaseManager,
         themeManager: ThemeManager,
         resultCalculator: ResultCalculator,
         pitchArray: Array<Double>) {
        
        self.databaseManager = databaseManager
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
        databaseManager.delegate = self
        databaseManager.getResults()
        setCurrentResult()
    }
    
    @IBAction func didPressDoneButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Private
    
    private func setAppearance() {
        
        activityIndicator.hidesWhenStopped = true
        view.backgroundColor = Color.getBackgroundColor()
        let buttonColor = Color.getInnerRecordButtonColor()
        let waveformColor = Color.getWaveformColor()
        let bordercolor = Color.getBorderColor()
        
        doneButton.setTitleColor(buttonColor, for: .normal)
        
        femaleLabel.textColor = Color.getTimeTextColor()
        androLabel.textColor = Color.getTimeTextColor()
        maleLabel.textColor = Color.getTimeTextColor()
        currentLabel.textColor = Color.getTimeTextColor()
        lastLabel.textColor = Color.getTimeTextColor()
        
        maleRangeLabel.textColor = Color.getSubTextColor()
        femaleRangeLabel.textColor = Color.getSubTextColor()
        
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
        
        databaseManager.setLastResult(result)
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

// MARK: - UITableViewDataSource UITableViewDelegate
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        UIView.performWithoutAnimation {
            cell.layoutIfNeeded()
        }
    }
}

// MARK: - DatabaseManagerDelegate
extension ResultViewController: DatabaseManagerDelegate {
    
    func databaseManager(didLoadData data: [RecorderResult]) {
        print("databaseManager didLoadData: \(data.count)")
        results = data.reversed()
        tableView.reloadData()
        setLastResult(data.last)
    }
    
    func databaseManager(didReceiveError error: Error) {
        print("databaseManager didReceiveError: \(error)")
    }
    
    func databaseManager(didUploadResultWithID documentID: String) {
        print("databaseManager didUploadResultWithID: \(documentID)")
    }
}
