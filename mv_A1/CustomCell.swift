//
//  CustomCell.swift
//  mv_A1
//
//  Created by 前沢光弘 on 2015/02/16.
//  Copyright (c) 2015年 Gris-Bleu. All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell {
	@IBOutlet var image:UIImageView!
	
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	required init(coder aDecoder: NSCoder){
		super.init(coder: aDecoder)
	}
}
