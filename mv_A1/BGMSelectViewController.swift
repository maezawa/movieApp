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
	var tune : Int!
	var myAudioPlayer : Array<AVAudioPlayer>! = nil

	@IBOutlet var btn1: UIButton!
	@IBOutlet var btn2: UIButton!
	@IBOutlet var btn3: UIButton!
	@IBOutlet var foot: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		let soundFilePath : Array<NSString> = [
			NSBundle.mainBundle().pathForResource("Pop1", ofType: "mp3")!,
			NSBundle.mainBundle().pathForResource("Pop1", ofType: "mp3")!,
			NSBundle.mainBundle().pathForResource("Pop1", ofType: "mp3")!
		]
		
		let fileURL : Array<NSURL> = [
			NSURL(fileURLWithPath: soundFilePath[0])!,
			NSURL(fileURLWithPath: soundFilePath[1])!,
			NSURL(fileURLWithPath: soundFilePath[2])!
		]
		
		myAudioPlayer = [
			AVAudioPlayer(contentsOfURL: fileURL[0], error: nil),
			AVAudioPlayer(contentsOfURL: fileURL[1], error: nil),
			AVAudioPlayer(contentsOfURL: fileURL[2], error: nil)
		]
		
		for (var i = 0; i < 3; i++){
			myAudioPlayer[i].delegate = self
			myAudioPlayer[i].prepareToPlay()
		}
		
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
	}
	
	@IBAction func onClickBtn1(sender: UIButton) {
		playMusic(1, sender: sender, myAudioPlayer: myAudioPlayer[0])
	}
	@IBAction func onClickBtn2(sender: UIButton) {
		playMusic(1, sender: sender, myAudioPlayer: myAudioPlayer[1])
	}
	@IBAction func onClickBtn3(sender: UIButton) {
		playMusic(1, sender: sender, myAudioPlayer: myAudioPlayer[2])
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
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.tune = indexPath.row + 1
	}
	
	override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let footerView = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, 64))
		let button = UIButton(frame: CGRectMake(0, 0, 140, 48))
		footerView.backgroundColor = UIColor.whiteColor()
		button.setTitle("ムービー作成", forState: .Normal)
		button.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 18.0)
		button.setTitleColor(UIColor.blueColor(), forState: .Normal)
		button.backgroundColor = UIColor.whiteColor()
		button.layer.position = CGPoint(x: footerView.frame.width / 2, y: 32)
		button.layer.borderWidth = 1
		button.layer.cornerRadius = 4
		button.layer.borderColor = UIColor.blueColor().CGColor
		button.addTarget(self, action: "toMerge", forControlEvents: .TouchUpInside)
		footerView.addSubview(button)
		
		return footerView
	}
	
	override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 48.0
	}
	
	@IBAction func toMerge(){
		self.performSegueWithIdentifier("toMerge", sender: self)
		println(self.tune)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "toMerge"){
			let MakingMovieViewController : makingMovieViewController = segue.destinationViewController as makingMovieViewController
			MakingMovieViewController.param = self.param
			MakingMovieViewController.tune = self.tune
		}
	}
}
