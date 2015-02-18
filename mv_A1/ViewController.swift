//
//  ViewController.swift
//  mv_A1
//
//  Created by Gris-Bleu on 2015/02/14.
//  Copyright (c) 2015年 Gris-Bleu. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class ViewController: UIViewController {
	@IBOutlet var movieCollection: [UICollectionView]!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationController?.navigationBarHidden = true
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	func getCount() -> Array<AnyObject>{
		let manager = NSFileManager.defaultManager()
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		let documentsDirectory = paths[0] as String // フォルダ.
		let list = manager.contentsOfDirectoryAtPath(documentsDirectory, error: nil)!
		return list
	}
	
	func getThumbnails() -> Array<UIImage>{
		var images:[UIImage] = []
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		let documentsDirectory = paths[0] as NSString // フォルダ.
		let filemanager : NSFileManager = NSFileManager()
		let files = filemanager.enumeratorAtPath(documentsDirectory)
		
		
		while let file: AnyObject = files?.nextObject() {
			let myFilePath = documentsDirectory.stringByAppendingPathComponent(file as String)
			let fileURL = NSURL(fileURLWithPath: myFilePath)
			let avAsset = AVURLAsset(URL: fileURL, options: nil)
			
			// assetから画像をキャプチャーする為のジュネレーターを生成.
			let generator = AVAssetImageGenerator(asset: avAsset)
			let time = CMTimeMakeWithSeconds(1.0, 1)
			var actualTime : CMTime = CMTimeMake(0, 0)
			var error : NSError?
			//generator.maximumSize = CGSize(width: 100, height: 100)
			
			// 動画の指定した時間での画像を得る.
			let capturedImage : CGImageRef! = generator.copyCGImageAtTime(time, actualTime: &actualTime, error: &error)
			let img = UIImage(CGImage: capturedImage!)
			images.append(img!)
		}
		
		return images
	}

	// MARK: - UICollectionViewDelegate Protocol
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell:CustomCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as CustomCell
		let list = getCount()
		let thumbnail = getThumbnails()
		cell.backgroundColor = UIColor.blackColor()
		cell.image.image = thumbnail[indexPath.item]
		
		return cell
	}
 
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
 
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let list = getCount()
		return list.count
	}
	
	// Make a Thumbnail
	func cropThumbnailImage(image :UIImage, w:Int, h:Int) ->UIImage{
		// リサイズ処理
		
		let origRef    = image.CGImage;
		let origWidth  = Int(CGImageGetWidth(origRef))
		let origHeight = Int(CGImageGetHeight(origRef))
		var resizeWidth:Int = 0, resizeHeight:Int = 0
		
		if (origWidth < origHeight) {
			resizeWidth = w
			resizeHeight = origHeight * resizeWidth / origWidth
		} else {
			resizeHeight = h
			resizeWidth = origWidth * resizeHeight / origHeight
		}
		
		let resizeSize = CGSizeMake(CGFloat(resizeWidth), CGFloat(resizeHeight))
		UIGraphicsBeginImageContext(resizeSize)
		
		image.drawInRect(CGRectMake(0, 0, CGFloat(resizeWidth), CGFloat(resizeHeight)))
		
		let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		// 切り抜き処理
		
		let cropRect  = CGRectMake(
			CGFloat((resizeWidth - w) / 2),
			CGFloat((resizeHeight - h) / 2),
			CGFloat(w), CGFloat(h))
		let cropRef   = CGImageCreateWithImageInRect(resizeImage.CGImage, cropRect)
		let cropImage = UIImage(CGImage: cropRef)
		
		return cropImage!
	}

	
	override func didReceiveMemoryWarning() {
			super.didReceiveMemoryWarning()
			// Dispose of any resources that can be recreated.
	}


}

