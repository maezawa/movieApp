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

    override func viewDidLoad() {
			super.viewDidLoad()
			
			// Do any additional setup after loading the view.
			var composition = AVMutableComposition()
			let trackVideo:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
			let trackAudio:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
			var insertTime = kCMTimeZero
			let movs = listFilesFromDocumentsFolder()
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
			
			
			let outputPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
			let completeMovie = outputPath.stringByAppendingPathComponent("movie.mp4")
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
					println("complete")
					UISaveVideoAtPathToSavedPhotosAlbum(completeMovie, nil, nil, nil)
				}
			})
    }

	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    

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

	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
