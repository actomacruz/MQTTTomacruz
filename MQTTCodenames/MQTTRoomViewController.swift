//
//  MQTTRoomViewController.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 31/08/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import UIKit

class MQTTRoomViewController: UIViewController, UIAlertViewDelegate {
    
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
        self.viewModel?.modelSignal.observeNext { [unowned self] next in
            self.statusTextView.text = self.statusTextView.text + "\n" + next
        }
        self.viewModel?.modelSignal.observeInterrupted { [unowned self] in
            if (!(self.viewModel!.roomCreator)) {
                let alertView = UIAlertView.init(title: "Oops", message: "Room creator has left the room", delegate: self, cancelButtonTitle: "OK")
                alertView.show()
            }
        }
        self.viewModel?.modelSignal.observeCompleted { [unowned self] in
            self.performSegueWithIdentifier("PresentGameRoom", sender: self)
        }
        self.startGameButton.hidden = !(self.viewModel!.roomCreator)
        self.startGameButton.enabled = false
        if (self.viewModel!.roomCreator) {
            self.viewModel?.playerIdArray.signal.observeNext { [unowned self] next in
                if (next.count >= 4) {
                    self.startGameButton.enabled = true
                }
                else {
                    self.startGameButton.enabled = false
                }
            }
        }
    }
    
    @IBAction func didTapStartGame(sender: AnyObject) {
        self.viewModel?.startGame()
    }
    
    @IBAction func didTapLeaveRoom(sender: AnyObject) {
        self.viewModel?.leaveRoom()
        if (self.viewModel!.roomCreator) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            self.performSegueWithIdentifier("UnwindForInitial", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch (identifier) {
            case "PresentGameRoom":
            let gameRoomViewController = segue.destinationViewController as! MQTTGameRoomViewController
            gameRoomViewController.viewModel = self.viewModel?.gameRoomViewModel()
            
            default: break
        }
    }
    
    // Mark UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.performSegueWithIdentifier("UnwindForInitial", sender: self)
    }
    
}