//
//  SortViewController.swift
//  mv_A1
//
//  Created by 前沢光弘 on 2015/02/23.
//  Copyright (c) 2015年 Gris-Bleu. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class SortViewController: UITableViewController{
	var param : Array<String> = []
	let files : Array<String> = []
	@IBOutlet weak var btnBGM: UIBarButtonItem!
	@IBOutlet weak var longpress: UILongPressGestureRecognizer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.rowHeight = 88.0
		self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "bg_2.png")!)
		longpress.minimumPressDuration = 0.5
		
		// Do any additional setup after loading the view.
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return param.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell : UITableViewCell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
		let movieFile = param[indexPath.row]
		let index = advance(movieFile.startIndex, 12)
		let a : String = movieFile.substringToIndex(index)
		let mo = NSMakeRange(4,2)
		let dd = NSMakeRange(6,2)
		let hh = NSMakeRange(8,2)
		let mm = NSMakeRange(10,2)
		let movieName = (a as NSString).substringToIndex(4) + "/" +
			(a as NSString).substringWithRange(mo) + "/" +
			(a as NSString).substringWithRange(dd) + " " +
			(a as NSString).substringWithRange(hh) + ":" +
			(a as NSString).substringWithRange(mm)
		cell.textLabel?.text = movieName
		
		let thumbnail = getThumbnails(movieFile)
		cell.imageView?.image = thumbnail
		cell.imageView?.frame = CGRectMake(0, 0, 80, 80)
		cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
		
		return cell
	}
	
	override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
		var itemToMove = param[sourceIndexPath.row]
		param.removeAtIndex(sourceIndexPath.row)
		param.insert(itemToMove, atIndex: destinationIndexPath.row)
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if(editingStyle == UITableViewCellEditingStyle.Delete){
			param.removeAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
		}
	}
	
	func getThumbnails(file: String) -> UIImage{
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
		let myFilePath = paths[0].stringByAppendingPathComponent(file)
		let fileURL = NSURL(fileURLWithPath: myFilePath)
		let avAsset = AVURLAsset(URL: fileURL, options: nil)
		
		// assetから画像をキャプチャーする為のジュネレーターを生成.
		let generator = AVAssetImageGenerator(asset: avAsset)
		let time = CMTimeMakeWithSeconds(1.0, 1)
		var actualTime : CMTime = CMTimeMake(0, 0)
		var error : NSError?
		
		// 動画の指定した時間での画像を得る.
		var capturedImage : CGImageRef! = generator.copyCGImageAtTime(time, actualTime: &actualTime, error: &error)
		let img = UIImage(CGImage: capturedImage!)
		var thumbnail = cropThumbnailImage(img!, w: 80, h: 80)
		capturedImage = nil

		return thumbnail
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
	
	@IBAction func longPress(sender: UILongPressGestureRecognizer) {
		if (sender.state == .Ended){ self.editing = !self.editing }
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "toBGM"){
			let bgmViewController:BGMSelectViewController = segue.destinationViewController as BGMSelectViewController
			bgmViewController.param = self.param
		}
	}

}
