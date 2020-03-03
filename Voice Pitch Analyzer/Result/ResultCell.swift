//
//  ResultCell.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/2/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet weak var calendarContainer: UIView!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowResultLabel: UILabel!
    @IBOutlet weak var highResultLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var rangeContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        guard let container = rangeContainer else {
            return
        }
        
//        container.layer.sublayers?.forEach { layer in
//            layer.removeFromSuperlayer()
//        }
               
        print("rangeContainer.layer.sublayers: \(container.layer.sublayers?.count)")
    }
    
    func bindViewModel(_ viewModel: Any) {
                
        guard let result = viewModel as? ResultCellContent else {
            return
        }
        
        backgroundColor = result.themeManager.getBackgroundColor()
        calendarContainer.backgroundColor = result.themeManager.getInnerRecordButtonColor()
        calendarContainer.layer.cornerRadius = 16
        
        lowLabel.textColor = result.themeManager.getSubTextColor()
        highLabel.textColor = result.themeManager.getSubTextColor()
        
        lowResultLabel.textColor = result.themeManager.getTimeTextColor()
        highResultLabel.textColor = result.themeManager.getTimeTextColor()
        
        lowResultLabel.text = result.result.getFormattedMin()
        highResultLabel.text = result.result.getFormattedMax()
        
        monthLabel.textColor = result.themeManager.getBackgroundColor()
        dayLabel.textColor = result.themeManager.getBackgroundColor()
        
        lowResultLabel.text = result.result.getFormattedMin()
        highResultLabel.text = result.result.getFormattedMax()
        
        monthLabel.text = result.result.getFormattedMonth(using: result.dateFormatter)
        dayLabel.text = result.result.getFormatteDay(using: result.dateFormatter)
        
        rangeContainer.backgroundColor = result.themeManager.getWaveformColor()
        rangeContainer.layer.cornerRadius = 4
        
        rangeContainer.setLayerBorderColor(result.themeManager.getBorderColor())
        rangeContainer.layer.setBorderColor(result.themeManager.getBorderColor(), with: rangeContainer)
        rangeContainer.layer.borderWidth = 1
        
        let layer = result.themeManager.getHistoryResultLayer(
            min: result.result.minAverage,
            max: result.result.maxAverage,
            on: rangeContainer)
        
        rangeContainer.layer.sublayers?.forEach { layer in
            //layer.removeFromSuperlayer()
            layer.opacity = 0
        }
        
        rangeContainer.layer.insertSublayer(layer, at: 0)
    }
}

struct ResultCellContent {
    
    public let result: RecorderResult
    public let themeManager: ThemeManager
    public let dateFormatter: DateFormatter
}
