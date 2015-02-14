//
//  MsgViewController.swift
//  mv_A1
//
//  Created by Gris-Bleu on 2015/02/14.
//  Copyright (c) 2015年 Gris-Bleu. All rights reserved.
//

import UIKit

class MsgViewController: UIViewController {
    @IBOutlet weak var MsgTextArea: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        
        MsgTextArea.layer.masksToBounds = true
        MsgTextArea.layer.cornerRadius = 4.0
        MsgTextArea.layer.borderWidth = 1
        MsgTextArea.layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1).CGColor
    }
    
    @IBAction func saveText(sender: AnyObject) {
        println(MsgTextArea.text)
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
