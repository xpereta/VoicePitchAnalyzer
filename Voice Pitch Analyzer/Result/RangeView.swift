//
//  RangeView.swift
//  Voice Pitch Analyzer
//
//  Created by Carola Nitz on 8/19/17.
//  Copyright © 2017 Carola Nitz. All rights reserved.
//

import UIKit

class RangeView: UIView {

    //65 to 525
    var min:Double
    var max:Double

    init(min:Double, max:Double) {
        self.min = min
        self.max = max
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSubviews(){
        let maleLabel = UILabel(frame: .zero)
        maleLabel.text = NSLocalizedString("Male\nRange", comment: "")
        maleLabel.numberOfLines = 0
        maleLabel.textAlignment = .right
        maleLabel.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(maleLabel)

        let androgynousLabel = UILabel(frame: .zero)
        androgynousLabel.text = NSLocalizedString("Androgynous\nRange", comment: "")
        androgynousLabel.numberOfLines = 0
        androgynousLabel.textAlignment = .right
        androgynousLabel.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(androgynousLabel)

        let femaleLabel = UILabel(frame: .zero)
        femaleLabel.text = NSLocalizedString("Female\nRange", comment: "")
        femaleLabel.numberOfLines = 0
        femaleLabel.textAlignment = .right
        femaleLabel.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(femaleLabel)

        NSLayoutConstraint.activate([
            femaleLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            femaleLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: -100),
            maleLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            maleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant:100),
            androgynousLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            androgynousLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ])
    }

    override func draw(_ rect: CGRect) {

        let currentContext = UIGraphicsGetCurrentContext();

        guard let context = currentContext else {
            return
        }
        self.clearsContextBeforeDrawing = true
        context.setFillColor(UIColor.white.cgColor)
        context.fill(bounds);

        let height = bounds.height;

        //femaleRange goes from 165hz - 255. The entire screen should show 340HZ
        //therefor 165 is 48.f percent of the screen and 255 is 75 percent
        //since we draw this upside down I have to take 1 -

        let upperFemaleRange = height * (1 - 0.4852)
        let lowerFemaleRange = height * (1 - 0.75)
        let femaleRange = CGRect(x:0, y:lowerFemaleRange, width: bounds.width, height:upperFemaleRange - lowerFemaleRange);
        context.setFillColor(red: 147.0/255.0, green: 112.0/255.0, blue: 219.0/255.0, alpha: 0.6);
        context.fill(femaleRange);
        //male range 85 to 180
        let upperMaleRange = height * (1 - 0.25)
        let lowerMaleRange = height * (1 - 0.5294)

        let maleRange = CGRect(x:0, y:lowerMaleRange, width: bounds.width, height: upperMaleRange - lowerMaleRange);
        context.setFillColor(red: 230.0/255.0, green: 230.0/255.0, blue: 255.0/255.0, alpha: 0.7);
        context.fill(maleRange);
        
        let yourmin = (1.0 - min/340)
        let yourmax = (1.0 - max/340)

        let recordingUpperRange = height * CGFloat(yourmin)
        let recordingLowerRange = height * CGFloat(yourmax)
        let yourRange = CGRect(x:bounds.width/2 - 25.0, y:recordingLowerRange, width: 50, height:recordingUpperRange - recordingLowerRange);

        let path = UIBezierPath(roundedRect: yourRange, cornerRadius: 20)
        context.setFillColor(red: 147.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.7);
        context.addPath(path.cgPath)
        context.fillPath()

        let middleOfRange = recordingUpperRange + (recordingLowerRange - recordingUpperRange)/2
        let middleOfyourRange = CGRect(x:bounds.width/2 - 25.0, y:middleOfRange - 1.5, width: 50, height: 3);
        context.setFillColor(red: 147.0/255.0, green: 147/255.0, blue: 147/255.0, alpha: 1);
        context.fill(middleOfyourRange);

    }
}
