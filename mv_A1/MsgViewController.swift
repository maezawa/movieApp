//
//  MsgViewController.swift
//  mv_A1
//
//  Created by Gris-Bleu on 2015/02/14.
//  Copyright (c) 2015年 Gris-Bleu. All rights reserved.
//

import UIKit
import AVFoundation

class MsgViewController: UIViewController {
	@IBOutlet weak var MsgTextArea: UITextView!

	override func viewDidLoad() {
		super.viewDidLoad()
        
//		self.navigationController?.navigationBarHidden = true
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg_2.png")!)
		MsgTextArea.layer.masksToBounds = true
		MsgTextArea.layer.cornerRadius = 4.0
		MsgTextArea.layer.borderWidth = 1
		MsgTextArea.layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1).CGColor
	}
    
	@IBAction func saveText(sender: AnyObject) {
		let msg : NSString! = MsgTextArea.text
		let boundsSize : CGSize = UIScreen.mainScreen().bounds.size
		let size : CGSize = CGSize(width: boundsSize.height, height: boundsSize.width)
		let myView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
		
		myView.backgroundColor = UIColor.blackColor()
		let label : UILabel = UILabel()
		label.text = msg
		label.textColor = UIColor.whiteColor()
		label.font = UIFont.systemFontOfSize(24)
		label.textAlignment = NSTextAlignment.Center
		label.setTranslatesAutoresizingMaskIntoConstraints(false)
		label.numberOfLines = 0
		label.sizeToFit()

		myView.addSubview(label)
		
		let viewsDictionary = ["msg": label];
		let constraints : NSMutableArray = NSMutableArray()
		let viewConstraintH : [AnyObject] = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[msg]-|", options: .AlignAllCenterX, metrics: nil, views: viewsDictionary)
		let viewConstraintV : [AnyObject] = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[msg]-|", options: .AlignAllCenterY, metrics: nil, views: viewsDictionary)
		constraints.addObjectsFromArray(viewConstraintH)
		constraints.addObjectsFromArray(viewConstraintV)
		myView.addConstraints(constraints)
		myView.setNeedsDisplay()
		myView.layoutIfNeeded()

		
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		myView.layer.renderInContext(UIGraphicsGetCurrentContext())
		let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
		let now = NSDate()
		let formatter = NSDateFormatter()
		formatter.locale = NSLocale(localeIdentifier: "en_US")
		formatter.dateFormat = "yyyyMMddHHmmss"

		
		var error : NSError?
		let movieName = path + "/" + formatter.stringFromDate(now) + "_txt.mov"
		let movieURL : NSURL = NSURL(fileURLWithPath: movieName)!
		let writer = AVAssetWriter(URL: movieURL, fileType: AVFileTypeMPEG4, error: &error)
		let videoSettings = [
			AVVideoCodecKey: AVVideoCodecH264,
			AVVideoWidthKey: size.width,
			AVVideoHeightKey: size.height
		]
		let input = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
		let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
		
		input.expectsMediaDataInRealTime = true
		writer.addInput(input)
		writer.startWriting()
		writer.startSessionAtSourceTime(kCMTimeZero)
		
		var buffer : CVPixelBufferRef
		let rect = CGRectMake(0, 0, size.width, size.height)
		let rectPtr  = UnsafeMutablePointer<CGRect>.alloc(1)
		let CGimage : CGImageRef = image.CGImage
		rectPtr.memory = rect
		buffer = pixelBufferFromCGImage(CGimage, size: size)
		var appendOk = false
		var j : Int64 = 0
		while (j < 50) {
			if pixelBufferAdaptor.assetWriterInput.readyForMoreMediaData {
				let frameTime = CMTimeMake(j * 30, 30)
				appendOk = pixelBufferAdaptor.appendPixelBuffer(buffer, withPresentationTime: frameTime)
			}
			j++
		}
		
		input.markAsFinished()
		
		writer.finishWritingWithCompletionHandler({
			if writer.status == AVAssetWriterStatus.Failed {
				println("Occurred an error \(writer)")
			}
		})
		
		// 保存しましたアラート
		let alert:UIAlertController = UIAlertController(title: "メッセージムービー作成完了", message: "メッセージを作成しました。", preferredStyle: .Alert)
		let backAction:UIAlertAction = UIAlertAction(
			title: "ムービーリストに戻る",
			style: .Default,
			handler: {
				(action:UIAlertAction!) -> Void in
				let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
				let hc : UINavigationController = storyboard.instantiateViewControllerWithIdentifier("nav") as UINavigationController
				self.presentViewController(hc, animated: true, completion: nil)
		})

		let cancelAction:UIAlertAction = UIAlertAction(title: "作成を続ける", style: .Cancel, handler: nil)
		alert.addAction(backAction)
		alert.addAction(cancelAction)
		presentViewController(alert, animated: true, completion: nil)
	}
	
	func pixelBufferFromCGImage(image: CGImageRef, size: CGSize) -> CVPixelBufferRef {
		
		let options = [
			"kCVPixelBufferCGImageCompatibilityKey": true,
			"kCVPixelBufferCGBitmapContextCompatibilityKey": true
		]
		
		var pixelBufferPointer = UnsafeMutablePointer<Unmanaged<CVPixelBuffer>?>.alloc(1)
		
		let buffered:CVReturn = CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image), CGImageGetHeight(image), OSType(kCVPixelFormatType_32ARGB), options, pixelBufferPointer)
		
		let lockBaseAddress = CVPixelBufferLockBaseAddress(pixelBufferPointer.memory?.takeUnretainedValue(), 0)
		var pixelData:UnsafeMutablePointer<(Void)> = CVPixelBufferGetBaseAddress(pixelBufferPointer.memory?.takeUnretainedValue())
		
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.NoneSkipFirst.rawValue)
		let space:CGColorSpace = CGColorSpaceCreateDeviceRGB()
		
		var context:CGContextRef = CGBitmapContextCreate(pixelData, CGImageGetWidth(image), CGImageGetHeight(image), 8, CVPixelBufferGetBytesPerRow(pixelBufferPointer.memory?.takeUnretainedValue()), space, bitmapInfo)
		
		CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(CGImageGetWidth(image)), CGFloat(CGImageGetHeight(image))), image)
		CVPixelBufferUnlockBaseAddress(pixelBufferPointer.memory?.takeUnretainedValue(), 0)
		
		return pixelBufferPointer.memory!.takeUnretainedValue()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}
