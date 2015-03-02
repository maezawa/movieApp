//
//  makingMovieViewController.swift
//  mv_A1
//
//  Created by 前沢光弘 on 2015/02/20.
//  Copyright (c) 2015年 Gris-Bleu. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class makingMovieViewController: UIViewController {
	var param : Array<String> = []
	var tune : Int!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		JHProgressHUD.sharedHUD.headerColor = UIColor.blueColor()
		JHProgressHUD.sharedHUD.footerColor = UIColor.blueColor()
		JHProgressHUD.sharedHUD.backGroundColor = UIColor.whiteColor()
		JHProgressHUD.sharedHUD.loaderColor = UIColor.blueColor()
		JHProgressHUD.sharedHUD.showInView(self.view, withHeader: "ムービー作成中", andFooter: "Wait a moment")
		
		println(param)
		println(tune)
		
		// Do any additional setup after loading the view.
		var composition = AVMutableComposition()
		let trackVideo:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
		let trackAudio:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
		// local mp3 file settinig
		let mp3FilePath = NSBundle.mainBundle().pathForResource("Pop" + String(tune), ofType: "mp3")!
		let mp3FileURL  = NSURL(fileURLWithPath: mp3FilePath)
		let mp3track:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())		
		let mp3Asset = AVURLAsset(URL: mp3FileURL, options: nil)
		let mp3 = mp3Asset.tracksWithMediaType(AVMediaTypeAudio)
		let assetTrackMp3:AVAssetTrack = mp3[0] as AVAssetTrack

		var insertTime = kCMTimeZero
		let movs = self.param
		let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
			
		for mov in movs{
			let moviePath = path.stringByAppendingPathComponent(mov)
			let moviePathUrl = NSURL(fileURLWithPath: moviePath)
			let sourceAsset = AVURLAsset(URL: moviePathUrl, options: nil)
			
			let tracks = sourceAsset.tracksWithMediaType(AVMediaTypeVideo)
			let audios = sourceAsset.tracksWithMediaType(AVMediaTypeAudio)
				
			if tracks.count > 0{
				let assetTrack:AVAssetTrack = tracks[0] as AVAssetTrack
				trackVideo.insertTimeRange(CMTimeRangeMake(kCMTimeZero,sourceAsset.duration), ofTrack: assetTrack, atTime: insertTime, error: nil)
					
				if audios.count > 0{
					let assetTrackAudio:AVAssetTrack = audios[0] as AVAssetTrack
						trackAudio.insertTimeRange(CMTimeRangeMake(kCMTimeZero,sourceAsset.duration), ofTrack: assetTrackAudio, atTime: insertTime, error: nil)
				}
					
				insertTime = CMTimeAdd(insertTime, sourceAsset.duration)
			}
		}
		
		mp3track.insertTimeRange(CMTimeRangeMake(kCMTimeZero, mp3Asset.duration), ofTrack: assetTrackMp3, atTime: kCMTimeZero, error: nil)
			
		
		let now = NSDate()
		let formatter = NSDateFormatter()
		formatter.locale = NSLocale(localeIdentifier: "en_US")
		formatter.dateFormat = "yyyyMMddHHmmss"
		let outputPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
		let completeMovie = outputPath.stringByAppendingPathComponent(formatter.stringFromDate(now) + ".mp4")
		let completeMovieUrl = NSURL(fileURLWithPath: completeMovie)
		println(completeMovieUrl)
		var exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
		exporter.outputURL = completeMovieUrl
		exporter.outputFileType = AVFileTypeMPEG4 //AVFileTypeQuickTimeMovie
		exporter.exportAsynchronouslyWithCompletionHandler({
			switch exporter.status{
			case  AVAssetExportSessionStatus.Failed:
				println("failed \(exporter.error)")
			case AVAssetExportSessionStatus.Cancelled:
				println("cancelled \(exporter.error)")
			default:
				self.finished(completeMovie)
			}
		})
	}
	
	// function to finished merging movies
	func finished(movie: String){
		UISaveVideoAtPathToSavedPhotosAlbum(movie, nil, nil, nil)
		JHProgressHUD.sharedHUD.hide()
		
		let alert : UIAlertController = UIAlertController(title: "ムービー完成", message: "作成したムービーは、カメラロールに保存しました。", preferredStyle: .Alert)
		let topAction : UIAlertAction = UIAlertAction(title: "OK",
			style: .Default,
			handler: {
				(action:UIAlertAction!)->Void in
				println("Go Back Top")
				self.performSegueWithIdentifier("toTop", sender: self)
		})
		alert.addAction(topAction)
		presentViewController(alert, animated: true, completion: nil)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "toTop"){
			let viewController : ViewController = segue.destinationViewController as ViewController
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    

/*
	func mergeVideos(path:String, outputPath:String, nMovie:Int){
		var composition = AVMutableComposition()
		let trackVideo:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
		let trackAudio:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
		var insertTime = kCMTimeZero
		let movs = listFilesFromDocumentsFolder()
		
		for mov in movs{
			let moviePath = path.stringByAppendingPathComponent(mov)
			let moviePathUrl = NSURL(fileURLWithPath: moviePath)
			let sourceAsset = AVURLAsset(URL: moviePathUrl, options: nil)
			
			let tracks = sourceAsset.tracksWithMediaType(AVMediaTypeVideo)
			let audios = sourceAsset.tracksWithMediaType(AVMediaTypeAudio)
			
			if tracks.count > 0{
				let assetTrack:AVAssetTrack = tracks[0] as AVAssetTrack
				trackVideo.insertTimeRange(CMTimeRangeMake(kCMTimeZero,sourceAsset.duration), ofTrack: assetTrack, atTime: insertTime, error: nil)
				let assetTrackAudio:AVAssetTrack = audios[0] as AVAssetTrack
				trackAudio.insertTimeRange(CMTimeRangeMake(kCMTimeZero,sourceAsset.duration), ofTrack: assetTrackAudio, atTime: insertTime, error: nil)
				insertTime = CMTimeAdd(insertTime, sourceAsset.duration)
			}
		}
		
		let outpath = UIImagePickerControllerMediaURL
		let completeMovie = outputPath.stringByAppendingPathComponent("movie.mov")
		let completeMovieUrl = NSURL(fileURLWithPath: completeMovie)
		var exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
		exporter.outputURL = completeMovieUrl
		exporter.outputFileType = AVFileTypeMPEG4 //AVFileTypeQuickTimeMovie
		exporter.exportAsynchronouslyWithCompletionHandler({
			switch exporter.status{
			case  AVAssetExportSessionStatus.Failed:
				println("failed \(exporter.error)")
			case AVAssetExportSessionStatus.Cancelled:
				println("cancelled \(exporter.error)")
			default:
				println("complete")
			}
		})
	}
	
	
	// ファイル一覧Get
	func listFilesFromDocumentsFolder() -> [String]{
		var theError = NSErrorPointer()
		var movList : Array<String> = [""]
		let dirs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
			NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
		
		if (dirs != nil){
			let dir = dirs![0]
			let fileList = NSFileManager.defaultManager().contentsOfDirectoryAtPath(dir, error: theError) as [String]
			let count = fileList.count
			movList.removeAtIndex(0)
			
			for (var i:Int = 0; i < count; i++){
				if (fileList[i].hasSuffix("mov")){
					movList.append(fileList[i])
				}
			}
			
			return movList
		}else{
			let movList = [""]
			return movList
		}
	}
*/

}
