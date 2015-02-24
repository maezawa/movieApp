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
	
		@IBOutlet var startBtn: UIButton!
		@IBOutlet var stopBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true

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
        let videoInput = AVCaptureDeviceInput.deviceInputWithDevice(myDevice, error: nil) as AVCaptureDeviceInput
        
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
        let myVideoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.layerWithSession(mySession) as AVCaptureVideoPreviewLayer
        myVideoLayer.frame = self.view.bounds
        myVideoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        // Viewに追加.
        self.view.layer.addSublayer(myVideoLayer)
        
        // セッション開始.
        mySession.startRunning()
			
        // 背景色を設定.
        startBtn.backgroundColor = UIColor.redColor();
				stopBtn.backgroundColor = UIColor.grayColor()
        
        // 枠を丸くする.
        startBtn.layer.masksToBounds = true
				stopBtn.layer.masksToBounds = true

			
        // コーナーの半径.
        startBtn.layer.cornerRadius = 20.0
				stopBtn.layer.cornerRadius = 20.0
        
        // ボタンの位置を指定.
        startBtn.layer.position = CGPoint(x: self.view.bounds.width/2 - 70, y:self.view.bounds.height - 50)
				stopBtn.layer.position = CGPoint(x: self.view.bounds.width / 2 + 70, y: self.view.bounds.height - 50)
        
        startBtn.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
				startBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
				stopBtn.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
				stopBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
			
        // UIボタンをViewに追加.
        self.view.addSubview(startBtn);
				self.view.addSubview(stopBtn)
    }
	
    
    // ボタンイベント.
		@IBAction func startBtn(sender: UIButton) {
			startBtn.enabled = false
			let now = NSDate()
			let timestamp = now.timeIntervalSince1970
			let outputFormat = NSDateFormatter()
			outputFormat.dateFormat = "yyyyMMddHHmmss"
			let fileName = outputFormat.stringFromDate(now)
			
			let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
			let documentsDirectory = paths[0] as String // フォルダ.
			let filePath : String? = "\(documentsDirectory)/\(fileName).mov" // ファイル名.
			let fileURL : NSURL = NSURL(fileURLWithPath: filePath!)! // URL.
			
			myVideoOutput.startRecordingToOutputFileURL(fileURL, recordingDelegate: self) // 録画開始.
		}

	
		@IBAction func stopBtn(sender: UIButton) {
			myVideoOutput.stopRecording()
		}
	
    //動画がキャプチャーされた後に呼ばれるメソッド.
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        println("didFinishRecordingToOutputFileAtURL")
    }
    
    //動画のキャプチャーが開始された時に呼ばれるメソッド.
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        println("didStartRecordingToOutputFileAtURL")
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
