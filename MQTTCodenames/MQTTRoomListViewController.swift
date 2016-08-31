//
//  MQTTRoomListViewController.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 01/09/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import UIKit
import ReactiveCocoa

class MQTTRoomListViewController: UITableViewController {
    
    var selectedTopic: String?
    var viewModel: MQTTRoomListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel?.modelSignal.observeNext { next in
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = self.viewModel?.roomListArray.count else {
            return 0
        }
        return count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("RoomListCellIdentifier") {
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            var roomName: String? = self.viewModel?.roomListArray[indexPath.row] as? String
            roomName = roomName?.componentsSeparatedByString("CocoaMQTT-")[1]
            cell.textLabel?.text = "Room " + roomName!
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let roomName: String? = self.viewModel?.roomListArray[indexPath.row] as? String
        self.selectedTopic = roomName?.componentsSeparatedByString(" - ")[1]
        self.performSegueWithIdentifier("PresentJoinedRoom", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch (identifier) {
            case "PresentJoinedRoom":
                let roomViewController = segue.destinationViewController as! MQTTRoomViewController
                roomViewController.viewModel = self.viewModel?.roomViewModel(self.selectedTopic!)
                roomViewController.roomCreator = false
            
            default: break
        }
    }
    
}