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
	@IBOutlet var checkButton: UIButton!
	@IBOutlet var sortButton: UIButton!
	@IBOutlet var toSortButton: UIBarButtonItem!
	
	let manager = NSFileManager.defaultManager()
	let files : Array<String>
	let paths : AnyObject
	let documentsDirectory : String
	var movList : Array<String>
	var cells : Array<Bool>
	var selectedMovie : Array<String>
	
	
	required init(coder aDecoder: NSCoder) {
		self.files = [""]
		self.paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		self.documentsDirectory = self.paths[0] as String
		self.movList = [""]
		self.cells = []
		self.selectedMovie = []
		super.init(coder: aDecoder)
		self.files = listFilesFromDocumentsFolder()
		self.cells = Array(count: self.files.count, repeatedValue: false)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
//		
//		let sortButton = UIButton()
//		sortButton.setTitle("ソート", forState: .Normal)
//		sortButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
//		sortButton.frame = CGRectMake(0, 0, 100.0, 24.0)
//		sortButton.backgroundColor = UIColor.whiteColor()
//		sortButton.layer.borderColor = UIColor.blueColor().CGColor
//		sortButton.layer.borderWidth = 1
//		sortButton.layer.cornerRadius = 4
//		let sortBarButton = UIBarButtonItem(customView: sortButton)
//		toSortButton = sortBarButton
//		self.navigationItem.rightBarButtonItem = toSortButton
		
//		self.navigationController?.navigationBarHidden = true
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	// MARK: - UICollectionViewDelegate Protocol
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		collectionView.allowsMultipleSelection = true
		let cell:CustomCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as CustomCell

		if (self.files.count > 0 && self.files[0] != ""){
			let thumbnail = getThumbnails(files)
			cell.backgroundColor = UIColor.blackColor()
			cell.image.image = thumbnail[indexPath.item]
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
			self.movList.removeAtIndex(0)
			
			for (var i:Int = 0; i < count; i++){
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


	
	override func didReceiveMemoryWarning() {
			super.didReceiveMemoryWarning()
			// Dispose of any resources that can be recreated.
	}


}

