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

	@IBOutlet var foot: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.rowHeight = 84.0

		
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
	
	override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let footerView = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, 64))
		let button = UIButton(frame: CGRectMake(0, 0, 120, 48))
		button.setTitle("BGM選択", forState: .Normal)
		button.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 18.0)
		button.setTitleColor(UIColor.blueColor(), forState: .Normal)
		button.backgroundColor = UIColor.whiteColor()
		button.layer.position = CGPoint(x: footerView.frame.width / 2, y: 32)
		button.layer.borderWidth = 1
		button.layer.cornerRadius = 4
		button.layer.borderColor = UIColor.blueColor().CGColor
		button.addTarget(self, action: "toBGM", forControlEvents: .TouchUpInside)
		footerView.addSubview(button)
		
		return footerView
	}
	
	override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 48.0
	}
	
	
	@IBAction func startEdit(sender: UIBarButtonItem){
		self.editing = !self.editing
	}
	
	@IBAction func toBGM(){
		println(param)
		self.performSegueWithIdentifier("tobgm", sender: self)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "tobgm"){
			let BGMViewController : BGMSelectViewController = segue.destinationViewController as BGMSelectViewController
			BGMViewController.param = self.param
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
		let capturedImage : CGImageRef! = generator.copyCGImageAtTime(time, actualTime: &actualTime, error: &error)
		let img = UIImage(CGImage: capturedImage!)
		let thumbnail = cropThumbnailImage(img!, w: 80, h: 80)
		
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
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
