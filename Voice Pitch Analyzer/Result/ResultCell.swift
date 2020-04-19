//
//  ResultCell.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/2/20.
//  Copyright © 2020 David Seek. All rights reserved.
//

import UIKit
import XYColor

class ResultCell: UITableViewCell {

    @IBOutlet weak var calendarContainer: UIView!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var medianLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowResultLabel: UILabel!
    @IBOutlet weak var medianResultLabel: UILabel!
    @IBOutlet weak var highResultLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var rangeContainer: UIView!

    private weak var theLayer: CALayer?
    private var resultCellContent: ResultCellContent?
    private var hasBeenReused: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        hasBeenReused = true
    }

    func bindViewModel(_ viewModel: Any) {

        guard let result = viewModel as? ResultCellContent else {
            return
        }

        resultCellContent = result
        backgroundColor = ColorCache.shared.getBackgroundColor()
        calendarContainer.backgroundColor = ColorCache.shared.getInnerRecordButtonColor()
        calendarContainer.layer.cornerRadius = 16

        lowLabel.textColor = ColorCache.shared.getSubTextColor()
        lowLabel.text = result.textManager.getLocalized(.low)

        medianLabel.textColor = ColorCache.shared.getSubTextColor()
        medianLabel.text = result.textManager.getLocalized(.median)

        highLabel.textColor = ColorCache.shared.getSubTextColor()
        highLabel.text = result.textManager.getLocalized(.high)

        lowResultLabel.textColor = ColorCache.shared.getTimeTextColor()
        lowResultLabel.text = result.result.getFormattedMedian()

        medianResultLabel.textColor = ColorCache.shared.getTimeTextColor()
        medianResultLabel.text = result.result.getFormattedMedian()

        highResultLabel.textColor = ColorCache.shared.getTimeTextColor()
        highResultLabel.text = result.result.getFormattedMax()

        monthLabel.textColor = ColorCache.shared.getBackgroundColor()
        dayLabel.textColor = ColorCache.shared.getBackgroundColor()

        lowResultLabel.text = result.result.getFormattedMin()
        highResultLabel.text = result.result.getFormattedMax()

        monthLabel.text = result.result.getFormattedMonth(using: result.dateFormatter)
        dayLabel.text = result.result.getFormatteDay(using: result.dateFormatter)

        rangeContainer.backgroundColor = ColorCache.shared.getWaveformColor()
        rangeContainer.layer.cornerRadius = 4

        rangeContainer.setLayerBorderColor(ColorCache.shared.getBorderColor())
        rangeContainer.layer.setBorderColor(ColorCache.shared.getBorderColor(), with: rangeContainer)
        rangeContainer.layer.borderWidth = 1

        setRange(result: result)

        if hasBeenReused == false {
            rangeContainer.addObserver(self, forKeyPath: #keyPath(UIView.bounds), options: .new, context: nil)
        }
    }

    // MARK: - Private

    private func setRange(result: ResultCellContent) {

        theLayer?.removeFromSuperlayer()

        let layer = result.themeManager.getHistoryResultLayer(
            min: result.result.minAverage,
            max: result.result.maxAverage,
            on: rangeContainer)

        rangeContainer.layer.insertSublayer(layer, at: 0)
        theLayer = layer
    }

    /**
     
    The KVO approach here fixes the issue,
    where the rangeContainer frame has not been set properly,
    and the layer had been set incorrectly.
     
    Setting needsLayout did not fix the issue.
    @author David Seek
     */
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?) {
        if let objectView = object as? UIView,
            objectView === rangeContainer,
            keyPath == #keyPath(UIView.bounds),
            let resultCellContent = resultCellContent {
            setRange(result: resultCellContent)
        }
    }
}

struct ResultCellContent {

    public let result: RecorderResult
    public let themeManager: ThemeManager
    public let textManager: TextManager
    public let dateFormatter: DateFormatter
}
