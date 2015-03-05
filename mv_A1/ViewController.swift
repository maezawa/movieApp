//
//  ViewController.swift
//  mv_A1
//
//  Created by Gris-Bleu on 2015/02/14.
//  Copyright (c) 2015年 Gris-Bleu. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import AssetsLibrary

class ViewController: UIViewController {
	@IBOutlet weak var toSortButton:UIBarButtonItem!
	@IBOutlet weak var longPress:UILongPressGestureRecognizer!
	@IBOutlet weak var collectionView:UICollectionView!
	@IBOutlet weak var delButton:UIBarButtonItem!
	@IBOutlet weak var container:UIView!
	
	let manager = NSFileManager.defaultManager()
	var files:Array<String>
	let paths:AnyObject
	let documentsDirectory:String
	var movList:Array<String>
	var cells:Array<Bool>
	var selectedMovie:Array<String>
	
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
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg_1.png")!)
		longPress.minimumPressDuration = 0.5
		delButton.enabled = false
		self.collectionView.addGestureRecognizer(longPress)
		container.frame = CGRectMake(0, 64.0, self.view.bounds.width, 180)
	}
	
	@IBAction func onClickdelButton(sender: AnyObject) {
		let cells = collectionView.indexPathsForSelectedItems()
		if (cells.count == 0){
			return
		}
		
		let files = cells.map({ self.movList[$0.item]})

		for file in files{
			NSFileManager.defaultManager().removeItemAtPath(self.documentsDirectory + "/" + file, error: nil)
		}
		
		let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let hc:UINavigationController = storyboard.instantiateViewControllerWithIdentifier("nav") as UINavigationController
		self.presentViewController(hc, animated: true, completion: nil)
	}
	
	@IBAction func longPress(sender: UILongPressGestureRecognizer) {
		if (sender.state != .Ended){
			delButton.enabled = !delButton.enabled
		}

		let a = self.collectionView.visibleCells() as Array<CustomCell>

		if (delButton.enabled == true){
			CATransaction.begin()
			CATransaction.setCompletionBlock { () -> Void in
				let rotate:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation")
				rotate.duration = 0.125
				rotate.repeatCount = MAXFLOAT
				rotate.fromValue = CGFloat(-2 * M_PI / 180) // 開始時の角度
				rotate.toValue = CGFloat(2 * M_PI / 180)
				
				for (var i = 0; i < a.count; i++){
					a[i].layer.addAnimation(rotate, forKey: "rotate-layer")
				}
			}
			CATransaction.commit()
		}else{
			for (var i = 0; i < a.count; i++){
				a[i].layer.removeAllAnimations()
			}
		}

	}
	
	// MARK: - UICollectionViewDelegate Protocol
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		collectionView.allowsMultipleSelection = true
		var cell:CustomCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as CustomCell
		let thumbnail = getThumbnails(files)

		if (files.count > 0 && files[0] != ""){
			cell.backgroundColor = UIColor.blackColor()
			cell.layer.cornerRadius = 8.0
			cell.clipsToBounds = true
			cell.image.image = thumbnail[indexPath.item]
			cell.userInteractionEnabled = true
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
		toSortButton.enabled = true
		container.layer.sublayers = nil
		var cell = collectionView.cellForItemAtIndexPath(indexPath)
		var isSelected = cell?.contentView.subviews[1] as UIImageView
		if (isSelected.highlighted){ self.cells[indexPath.item] = true }

		var file:String = self.movList[indexPath.item]
		var url:NSURL = NSURL(fileURLWithPath: self.documentsDirectory + "/" + file)!
		
		var asset:AVAsset = AVAsset.assetWithURL(url) as AVAsset
		var playerItem:AVPlayerItem = AVPlayerItem(asset: asset)
		var avPlayer:AVPlayer = AVPlayer.playerWithPlayerItem(playerItem) as AVPlayer
		var avPlayerLayer:AVPlayerLayer = AVPlayerLayer(player: avPlayer)

		if (file.rangeOfString("_txt") == nil){ avPlayerLayer.transform = CATransform3DMakeRotation(CGFloat(M_PI * 270 / 180), 0, 0, 1) }
		
		avPlayerLayer.frame = CGRectMake(0, 0, container.bounds.width, container.bounds.height)
		container.layer.addSublayer(avPlayerLayer)
		avPlayer.play()
	}
	
	func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath){
		let cells = collectionView.indexPathsForSelectedItems()
		if (cells.count == 0){ toSortButton.enabled = false }
		let cell = collectionView.cellForItemAtIndexPath(indexPath)
		let isSelected = cell?.contentView.subviews[1] as UIImageView
		if (isSelected.highlighted != true){ self.cells[indexPath.item] = false }
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
			var capturedImage : CGImageRef! = generator.copyCGImageAtTime(time, actualTime: &actualTime, error: &error)
			let img = UIImage(CGImage: capturedImage!)
			var thumbnail = cropThumbnailImage(img!, w: 90, h: 90)
			images.append(thumbnail)
			capturedImage = nil
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
		
		if (origWidth < origHeight){
			resizeWidth = w
			resizeHeight = origHeight * resizeWidth / origWidth
		}else{
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

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
		if (segue.identifier == "forSort"){
			let sortViewController:SortViewController = segue.destinationViewController as SortViewController
			for (var i = 0; i < cells.count; i++){
				if (cells[i] == true){
					selectedMovie.append(movList[i])
				}
			}
			sortViewController.param = self.selectedMovie
		}
	}
	
	override func didReceiveMemoryWarning() {
			super.didReceiveMemoryWarning()
			// Dispose of any resources that can be recreated.
	}


}

