//
//  RecMovieViewController.swift
//  mv_A1
//
//  Created by Gris-Bleu on 2015/02/14.
//  Copyright (c) 2015年 Gris-Bleu. All rights reserved.
//

import UIKit
import AVFoundation

class RecMovieViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
	// セッション.
	var mySession : AVCaptureSession!
	// デバイス.
	var myDevice : AVCaptureDevice!
	// 画像のアウトプット.
	var myImageOutput : AVCaptureStillImageOutput!
	// ビデオのアウトプット.
	var myVideoOutput : AVCaptureMovieFileOutput!
	// スタートボタン.
	var myButtonStart : UIButton!
	// ストップボタン.
	var myButtonStop : UIButton!
	var videoInput : AVCaptureDeviceInput!
	
	@IBOutlet var startBtn: UIButton!
	@IBOutlet var myVideoLayer: AVCaptureVideoPreviewLayer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
		self.navigationController?.navigationBarHidden = true

		let swipeLeft:UISwipeGestureRecognizer  = UISwipeGestureRecognizer(target: self, action: "swipeLeft:")
		swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
		self.view.addGestureRecognizer(swipeLeft)
		
		let pinch:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "pinchZoom:")
		self.view.addGestureRecognizer(pinch)
		
		// セッションの作成.
		mySession = AVCaptureSession()
        
		// デバイス一覧の取得.
		let devices = AVCaptureDevice.devices()
        
		// バックライトをmyDeviceに格納.
		for device in devices{
				if(device.position == AVCaptureDevicePosition.Back){
					myDevice = device as AVCaptureDevice
				}
		}
        
		// バックカメラを取得.
		videoInput = AVCaptureDeviceInput.deviceInputWithDevice(myDevice, error: nil) as AVCaptureDeviceInput
        
		// ビデオをセッションのInputに追加.
		mySession.addInput(videoInput)
        
		// マイクを取得.
		let audioCaptureDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio)
        
		// マイクをセッションのInputに追加.
		let audioInput = AVCaptureDeviceInput.deviceInputWithDevice(audioCaptureDevice[0] as AVCaptureDevice, error: nil)  as AVCaptureInput
        
		// オーディオをセッションに追加.
		mySession.addInput(audioInput);
        
		// 出力先を生成.
		myImageOutput = AVCaptureStillImageOutput()
        
		// セッションに追加.
		mySession.addOutput(myImageOutput)
        
		// 動画の保存.
		myVideoOutput = AVCaptureMovieFileOutput()
        
		// ビデオ出力をOutputに追加.
		mySession.addOutput(myVideoOutput)

		// 画像を表示するレイヤーを生成.
		myVideoLayer = AVCaptureVideoPreviewLayer.layerWithSession(mySession) as AVCaptureVideoPreviewLayer
		myVideoLayer.frame = self.view.bounds
		myVideoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
		// Viewに追加.
		self.view.layer.addSublayer(myVideoLayer)
        
		// セッション開始.
		mySession.startRunning()
			
		// UIボタンをViewに追加.
		self.view.addSubview(startBtn);
	}
	
    
	// ボタンイベント.
	@IBAction func startBtn(sender: UIButton) {
		let now = NSDate()
		let timestamp = now.timeIntervalSince1970
		let outputFormat = NSDateFormatter()
		outputFormat.dateFormat = "yyyyMMddHHmmss"
		let fileName = outputFormat.stringFromDate(now)
			
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		let documentsDirectory = paths[0] as String // フォルダ.
		let filePath : String? = "\(documentsDirectory)/\(fileName).mov" // ファイル名.
		let fileURL : NSURL = NSURL(fileURLWithPath: filePath!)! // URL.
			
		myVideoOutput.maxRecordedDuration = CMTimeMake(30 * 30, 30)
		myVideoOutput.startRecordingToOutputFileURL(fileURL, recordingDelegate: self) // 録画開始.
		let timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "stopRec", userInfo: nil, repeats: false)
	}

	
	func stopRec() {
		myVideoOutput.stopRecording()
		startBtn.setImage(UIImage(named: "rec.png"), forState: .Normal)
		
		let alert : UIAlertController = UIAlertController(title: "録画完了", message: "録画が完了しました。\nこのまま録画モードに戻りますか？", preferredStyle: .Alert)
		let recAction : UIAlertAction = UIAlertAction(
			title: "録画モードに戻る",
			style: .Cancel,
			handler: {
				(action:UIAlertAction!)->Void in
				println("Go back to rec mode")
		})
		let topAction : UIAlertAction = UIAlertAction(
			title: "ムービーリストに戻る",
			style: .Default,
			handler:{
				(action:UIAlertAction!) -> Void in
				println("Go back to Main")
				self.backtoMain()
		})
		alert.addAction(recAction)
		alert.addAction(topAction)
		presentViewController(alert, animated: true, completion: nil)
	}
	
	//動画がキャプチャーされた後に呼ばれるメソッド.
	func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
	}
    
	//動画のキャプチャーが開始された時に呼ばれるメソッド.
	func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
		startBtn.setImage(UIImage(named: "stop.png"), forState: .Normal)
	}
	
	func swipeLeft(sender: UISwipeGestureRecognizer){
		self.backtoMain()
	}
	
	func pinchZoom(sender: UIPinchGestureRecognizer){
		var error:NSError? = nil
		var currentZoomScale:CGFloat = 1.0
		let maxZoomScale = myDevice.activeFormat.videoMaxZoomFactor
		
		if (myDevice.lockForConfiguration(&error)){
			currentZoomScale *= sender.scale

			if (currentZoomScale < 1.0){
				currentZoomScale = 1.0
			}else if(maxZoomScale < currentZoomScale){
				currentZoomScale = maxZoomScale
			}

			myDevice.rampToVideoZoomFactor(currentZoomScale, withRate: 5.0)
			myDevice.unlockForConfiguration()
		}else{
			println("Error \(error)")
		}
	}
	
	func backtoMain(){
		self.mySession.removeInput(self.videoInput)
		self.mySession.removeOutput(self.myVideoOutput)
		let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let hc : UINavigationController = storyboard.instantiateViewControllerWithIdentifier("nav") as UINavigationController
		self.presentViewController(hc, animated: true, completion: nil)
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
