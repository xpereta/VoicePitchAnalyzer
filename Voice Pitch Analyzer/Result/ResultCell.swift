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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
    }
}

struct ResultCellContent {
    
    public let result: RecorderResult
    public let themeManager: ThemeManager
    public let dateFormatter: DateFormatter
}
