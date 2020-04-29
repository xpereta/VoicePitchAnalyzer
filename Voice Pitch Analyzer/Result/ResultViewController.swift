//
//  ResultViewController.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 David Seek. All rights reserved.
//

import UIKit
import XYColor

class ResultViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var rangeContainer: UIView!
    @IBOutlet weak var innerRangeContainer: UIView!
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
    private let textManager: TextManager
    private let pitchArray: [Double]

    private var results = [RecorderResult]()
    private var currentResult: RecorderResult?

    private lazy var dateFormatter: DateFormatter = {
        return DateFormatter()
    }()

    init(databaseManager: DatabaseManager,
         themeManager: ThemeManager,
         resultCalculator: ResultCalculator,
         textManager: TextManager,
         pitchArray: [Double]) {

        self.databaseManager = databaseManager
        self.themeManager = themeManager
        self.resultCalculator = resultCalculator
        self.textManager = textManager
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
        displayCurrentResult()
    }

    @IBAction func didPressDoneButton(_ sender: Any) {
        dismiss(animated: true)
    }

    // MARK: - Private

    private func setAppearance() {

        activityIndicator.hidesWhenStopped = true
        view.backgroundColor = ColorCache.shared.getBackgroundColor()
        let buttonColor = ColorCache.shared.getInnerRecordButtonColor()
        let waveformColor = ColorCache.shared.getWaveformColor()
        let bordercolor = ColorCache.shared.getBorderColor()

        doneButton.setTitleColor(buttonColor, for: .normal)
        doneButton.setTitle(textManager.getLocalized(.done), for: .normal)

        femaleLabel.textColor = ColorCache.shared.getTimeTextColor()
        femaleLabel.text = textManager.getLocalized(.female)

        androLabel.textColor = ColorCache.shared.getTimeTextColor()
        androLabel.text = textManager.getLocalized(.androgynous)

        maleLabel.textColor = ColorCache.shared.getTimeTextColor()
        maleLabel.text = textManager.getLocalized(.male)

        currentLabel.textColor = ColorCache.shared.getTimeTextColor()
        currentLabel.text = textManager.getLocalized(.current)

        lastLabel.textColor = ColorCache.shared.getTimeTextColor()
        lastLabel.text = textManager.getLocalized(.last)

        maleRangeLabel.textColor = ColorCache.shared.getSubTextColor()
        femaleRangeLabel.textColor = ColorCache.shared.getSubTextColor()

        rangeContainer.backgroundColor = waveformColor
        rangeContainer.layer.cornerRadius = 16

        rangeContainer.setLayerBorderColor(bordercolor)
        rangeContainer.layer.setBorderColor(bordercolor, with: rangeContainer)
        rangeContainer.layer.borderWidth = 1
    }

    /**
     Upload current result to Firebase if the frequency is of interest.
     Might be 0 if the user dismisses the recording process to soon. */
    private func storeResult(min minAverage: Double, max maxAverage: Double) {

        guard let userID = databaseManager.getUserID() else { return }
        guard minAverage > 0, maxAverage > 0 else { return }

        let result = RecorderResult(
            minAverage: minAverage,
            maxAverage: maxAverage,
            userID: userID)

        currentResult = result
        databaseManager.setLastResult(result)
    }

    private func displayLastResult(_ result: RecorderResult?) {

        guard let result = result else {
            return
        }

        let layer = themeManager.getLastResultLayer(
            min: result.minAverage,
            max: result.maxAverage,
            on: innerRangeContainer)

        innerRangeContainer.layer.addSublayer(layer)
    }

    private func displayCurrentResult() {

        let maxAverage = resultCalculator.getAverage(of: pitchArray, getMax: true)
        let minAverage = resultCalculator.getAverage(of: pitchArray, getMax: false)

        guard minAverage > 0,
            maxAverage > 0 else {
                return
        }

        storeResult(min: minAverage, max: maxAverage)

        let layer = themeManager.getCurrentResultLayer(
            min: minAverage,
            max: maxAverage,
            on: innerRangeContainer)

        innerRangeContainer.layer.addSublayer(layer)
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
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ResultCell",
            for: indexPath) as? ResultCell else {
            fatalError("Error loading ResultCell. This should never happen.")
        }

        let content = ResultCellContent(
            result: result,
            themeManager: themeManager,
            textManager: textManager,
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

        guard let last = data.last else { return }

        if let result = currentResult, result.uuid == last.uuid {
            return
        }

        displayLastResult(last)
    }

    /** Log already added in manager class. */
    func databaseManager(didReceiveError error: Error) {
        print("databaseManager didReceiveError: \(error)")
    }

    /** Might want to add UI feedback for successful storing results? */
    func databaseManager(didUploadResultWithID documentID: String) {
        print("databaseManager didUploadResultWithID: \(documentID)")
    }
}
