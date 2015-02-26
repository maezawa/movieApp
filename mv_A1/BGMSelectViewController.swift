//
//  BGMSelectViewController.swift
//  mv_A1
//
//  Created by 前沢光弘 on 2015/02/25.
//  Copyright (c) 2015年 Gris-Bleu. All rights reserved.
//

import UIKit
import AVFoundation

class BGMSelectViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
	var param : Array<String> = []
	var myAudioPlayer : AVAudioPlayer! = nil

	@IBOutlet var btn1: UIButton!
	@IBOutlet var btn2: UIButton!
	@IBOutlet var btn3: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		let soundFilePath : NSString = NSBundle.mainBundle().pathForResource("Pop1", ofType: "mp3")!
		let fileURL : NSURL = NSURL(fileURLWithPath: soundFilePath)!
		myAudioPlayer = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
		myAudioPlayer.delegate = self
		myAudioPlayer.prepareToPlay()
		
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
	}
	
	@IBAction func onClickBtn1(sender: UIButton) {
		playMusic(1, sender: sender, myAudioPlayer: myAudioPlayer)
	}
	@IBAction func onClickBtn2(sender: UIButton) {
		playMusic(1, sender: sender, myAudioPlayer: myAudioPlayer)
	}
	@IBAction func onClickBtn3(sender: UIButton) {
		playMusic(1, sender: sender, myAudioPlayer: myAudioPlayer)
	}
	
	
	func playMusic(num: Int, sender: UIButton, myAudioPlayer: AVAudioPlayer){
		let num = String(num)
		let playBtn : UIImage = UIImage(named: "play.png")!
		let stopBtn : UIImage = UIImage(named: "stop.png")!
		if myAudioPlayer.playing == true {
			
			//myAudioPlayerを一時停止.
			myAudioPlayer.pause()
			sender.setImage(playBtn, forState: .Normal)
		} else {
			
			//myAudioPlayerの再生.
			myAudioPlayer.play()
			sender.setImage(stopBtn, forState: .Normal)
		}
	}
	
	
	func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool, sender: UIButton) {
		println("Music Finish")
		let playBtn : UIImage = UIImage(named: "play.png")!

		//再度myButtonを"▶︎"に設定.
		sender.setImage(playBtn, forState: .Normal)
	}
	
	//デコード中にエラーが起きた時に呼ばれるメソッド.
	func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
		println("Error")
	}

	override func didReceiveMemoryWarning() {
			super.didReceiveMemoryWarning()
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
		return cell
	}
	
	override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
		println(indexPath.row)
	}

}
