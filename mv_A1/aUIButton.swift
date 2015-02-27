//
//  aUIButton.swift
//  mv_A1
//
//  Created by 前沢光弘 on 2015/02/27.
//  Copyright (c) 2015年 Gris-Bleu. All rights reserved.
//

import Foundation
import UIKit

class aUIButton: UIButton {

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.layer.cornerRadius = 4.0
		self.layer.borderWidth = 1.0
		self.layer.borderColor = UIColor.blueColor().CGColor
//		self.layer.shadowColor = UIColor(red: 48/255, green: 106/255, blue: 180/255, alpha: 1).CGColor
//		self.layer.shadowOffset = CGSizeMake(2, 2)
		self.backgroundColor = UIColor.whiteColor()
		self.setTitleColor(UIColor.blueColor(), forState: .Normal)
		self.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 16.0)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
