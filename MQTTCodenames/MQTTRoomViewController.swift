//
//  MQTTRoomViewController.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 31/08/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import UIKit

class MQTTRoomViewController: UIViewController {

    var viewModel: MQTTRoomViewModel?
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var leaveRoomButton: UIButton!
    @IBOutlet weak var statusTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didTapStartGame(sender: AnyObject) {
        print("Start Game")
    }
    
    @IBAction func didTapLeaveRoom(sender: AnyObject) {
        self.viewModel?.leaveRoom()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}