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

    var viewModel: MQTTRoomListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DynamicProperty(object: self.viewModel, keyPath: "roomListArray").signal.observeNext { next in
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
            cell.textLabel?.text = roomName
            return cell
        }
        return UITableViewCell()
    }
    
}