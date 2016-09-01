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
    
    var selectedRoom: Int?
    var viewModel: MQTTRoomListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel?.roomListArray.signal.observeNext { next in
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = self.viewModel?.roomListArray.value.count else {
            return 0
        }
        return count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("RoomListCellIdentifier") {
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            var roomName: String? = self.viewModel?.roomListArray.value[indexPath.row]
            roomName = roomName?.componentsSeparatedByString("CocoaMQTT-")[1]
            cell.textLabel?.text = "Room " + roomName!
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedRoom = indexPath.row
        self.viewModel?.unsubscribe()
        self.performSegueWithIdentifier("PresentJoinedRoom", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch (identifier) {
            case "PresentJoinedRoom":
                let roomViewController = segue.destinationViewController as! MQTTRoomViewController
                roomViewController.viewModel = self.viewModel?.roomViewModel(self.selectedRoom!, roomCreator: false)
            
            default: break
        }
    }
    
}