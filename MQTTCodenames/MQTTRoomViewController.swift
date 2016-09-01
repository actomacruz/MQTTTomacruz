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
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var leaveRoomButton: UIButton!
    @IBOutlet weak var statusTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let roomName = self.viewModel?.roomName() else {
            self.roomNameLabel.text = "Room Created"
            return
        }
        self.roomNameLabel.text = "Room " + roomName
        self.viewModel?.modelSignal.observeNext { next in
            self.statusTextView.text = self.statusTextView.text + "\n" + next
        }
        self.viewModel?.modelSignal.observeInterrupted {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                let alertView = UIAlertView.init(title: "Oops", message: "Room creator has left the room", delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            })
        }
        self.startGameButton.hidden = !((self.viewModel?.roomCreator)!)
    }
    
    @IBAction func didTapStartGame(sender: AnyObject) {
        print("Start Game")
    }
    
    @IBAction func didTapLeaveRoom(sender: AnyObject) {
        self.viewModel?.leaveRoom()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}