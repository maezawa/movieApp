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
        let msg : NSString! = MsgTextArea.text
        let size : CGSize = UIScreen.mainScreen().bounds.size
        let myView : UIView = UIView(frame: CGRect(origin: CGPointZero, size: size ))
        
        myView.backgroundColor = UIColor.blackColor()
        let label : UILabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        label.text = msg
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(20)
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 0
        label.sizeToFit()
        label.layer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        myView.addSubview(label)
        
        UIGraphicsBeginImageContextWithOptions(myView.frame.size, false, 0)
        myView.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let saveImage : NSData = UIImagePNGRepresentation(image)
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let now = NSDate()
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = "/" + formatter.stringFromDate(now) + ".png"
        
        saveImage.writeToFile(path + fileName, atomically: true)
        
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
