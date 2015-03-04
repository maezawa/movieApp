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
	@IBOutlet var toSortButton: UIBarButtonItem!
	@IBOutlet var longPress: UILongPressGestureRecognizer!
	@IBOutlet var collectionView: UICollectionView!
	
	let manager = NSFileManager.defaultManager()
	var files : Array<String>
	let paths : AnyObject
	let documentsDirectory : String
	var movList : Array<String>
	var cells : Array<Bool>
	var selectedMovie : Array<String>
	
	required init(coder aDecoder: NSCoder) {
		self.files = [""]
		self.paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		self.documentsDirectory = self.paths[0] as String
		self.movList = []
		self.cells = []
		self.selectedMovie = []
		super.init(coder: aDecoder)
		self.files = listFilesFromDocumentsFolder()
		self.cells = Array(count: self.files.count, repeatedValue: false)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		longPress.minimumPressDuration = 0.5
		self.collectionView.addGestureRecognizer(longPress)
	}
	
	@IBAction func longPress(sender: UILongPressGestureRecognizer) {
		if (sender.state != .Ended){
			return
		}
		
		let cell:CustomCell = sender.view as CustomCell
		let p:CGPoint = sender.locationInView(self.collectionView)
		let indexPath: NSIndexPath = self.collectionView.indexPathForItemAtPoint(p)!
		let actionIndexPath = indexPath.item
		let actionFile = self.movList[actionIndexPath]
		
		let alert:UIAlertController = UIAlertController(title: "この動画をプレビューしますか？削除しますか？", message: "", preferredStyle: .Alert)
		let previewAction:UIAlertAction = UIAlertAction(
			title: "プレビューする",
			style: .Default,
			handler: {(action:UIAlertAction!) -> Void in
				println()
		})
		
		let delAction:UIAlertAction = UIAlertAction(
			title: "削除する",
			style: .Default,
			handler: {(action:UIAlertAction!) -> Void in
				println(actionFile)
				self.deleteFiles(actionFile)
		})
		
		let cancelAction:UIAlertAction = UIAlertAction(
			title: "キャンセル",
			style: .Cancel,
			handler: nil
		)
		alert.addAction(previewAction)
		alert.addAction(delAction)
		alert.addAction(cancelAction)
		presentViewController(alert, animated: true, completion: nil)
		/*
			if (delButton.enabled == true){
				CATransaction.begin()
				CATransaction.setCompletionBlock { () -> Void in
					let rotate:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation")
					rotate.duration = 0.125
					rotate.repeatCount = MAXFLOAT
					rotate.fromValue = CGFloat(-2 * M_PI / 180) // 開始時の角度
					rotate.toValue = CGFloat(2 * M_PI / 180)
					let a = self.collectionView.visibleCells() as Array<CustomCell>
					
					for (var i = 0; i < a.count; i++){
						a[i].layer.addAnimation(rotate, forKey: "rotate-layer")
					}
				}
				CATransaction.commit()
			}else{
				let a = self.collectionView.visibleCells() as Array<CustomCell>
			
				for (var i = 0; i < a.count; i++){
					a[i].layer.removeAllAnimations()
				}
			}
		*/
		
	}
	
	// MARK: - UICollectionViewDelegate Protocol
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		collectionView.allowsMultipleSelection = true
		let cell:CustomCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as CustomCell

		if (self.files.count > 0 && self.files[0] != ""){
			let thumbnail = getThumbnails(files)
			cell.backgroundColor = UIColor.blackColor()
			cell.image.image = thumbnail[indexPath.item]
			cell.userInteractionEnabled = true
			
//			CATransaction.begin()
//			CATransaction.setAnimationDuration(0.5)
		}else{
			println("You've not taken any movies.")
		}
		return cell
	}
 
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
 
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.files.count
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
		let cell = collectionView.cellForItemAtIndexPath(indexPath)
		let isSelected = cell?.contentView.subviews[1] as UIImageView
		if (isSelected.highlighted){ self.cells[indexPath.item] = true }
	}
	
	func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath){
		let cell = collectionView.cellForItemAtIndexPath(indexPath)
		let isSelected = cell?.contentView.subviews[1] as UIImageView
		if (isSelected.highlighted != true){ self.cells[indexPath.item] = false }
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
		if (segue.identifier == "forSort"){
			let sortViewController: SortViewController = segue.destinationViewController as SortViewController
			for (var i = 0; i < cells.count; i++){
				if (cells[i] == true){
					selectedMovie.append(movList[i])
				}
			}
			sortViewController.param = self.selectedMovie
		}
	}
	
	func getThumbnails(files: Array<String>) -> Array<UIImage>{
		var images:[UIImage] = []

		for file in self.files {
			let myFilePath = self.documentsDirectory.stringByAppendingPathComponent(file as String)
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
			let thumbnail = cropThumbnailImage(img!, w: 640, h: 640)
			images.append(thumbnail)
		}
		
		return images
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
	
	// ファイル一覧Get
	func listFilesFromDocumentsFolder() -> [String]{
		var theError = NSErrorPointer()
		let dirs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
			NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
		
		if (dirs != nil){
			let dir = dirs![0]
			let fileList = NSFileManager.defaultManager().contentsOfDirectoryAtPath(dir, error: theError) as [String]
			let count = fileList.count
			
			for (var i = 0; i < count; i++){
				if (fileList[i].hasSuffix("mov")){
					self.movList.append(fileList[i])
				}
			}
			return self.movList
		}else{
			let movList = [""]
			return movList
		}
	}
	
	func deleteFiles(delFile: String){
		NSFileManager.defaultManager().removeItemAtPath(self.documentsDirectory + "/" + delFile, error: nil)
		
		//collectionView.reloadData()
		let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let hc : UINavigationController = storyboard.instantiateViewControllerWithIdentifier("nav") as UINavigationController
		self.presentViewController(hc, animated: true, completion: nil)
	}
	
	override func didReceiveMemoryWarning() {
			super.didReceiveMemoryWarning()
			// Dispose of any resources that can be recreated.
	}


}

