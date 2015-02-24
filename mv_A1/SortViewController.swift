//
//  SortViewController.swift
//  mv_A1
//
//  Created by 前沢光弘 on 2015/02/23.
//  Copyright (c) 2015年 Gris-Bleu. All rights reserved.
//

import UIKit

class SortViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
	@IBOutlet var tableView: UITableView!
	
	var param : Array<String> = []

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return param.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell : UITableViewCell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
		cell.textLabel?.text = param[indexPath.row]
		return cell
	}
	
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == UITableViewCellEditingStyle.Delete {
			param.removeAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
		}
	}
	
	func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
		var itemToMove = param[sourceIndexPath.row]
		param.removeAtIndex(sourceIndexPath.row)
		param.insert(itemToMove, atIndex: destinationIndexPath.row)
	}
	
	func tableView(tableView: UITableView!, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath!, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath!) -> NSIndexPath{
		let section:AnyObject = param[sourceIndexPath.section]
		var sectionCount = param.count as NSInteger
		if sourceIndexPath.section != proposedDestinationIndexPath.section{
			var rowinSourceSection:NSInteger =  (sourceIndexPath.section > proposedDestinationIndexPath.section) ? 0 : (sectionCount-1)
			
			return NSIndexPath(forRow: rowinSourceSection, inSection: sourceIndexPath.row)
		}else if proposedDestinationIndexPath.row >= sectionCount{
			return NSIndexPath(forRow: (sectionCount-1), inSection: sourceIndexPath.row)
		}
		
		return proposedDestinationIndexPath
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
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
