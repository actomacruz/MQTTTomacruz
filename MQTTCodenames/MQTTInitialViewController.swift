//
//  MQTTInitialViewController.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 13/07/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import UIKit
import ReactiveCocoa
import enum Result.NoError

class MQTTInitialViewController: UIViewController {
    
    var viewModel: MQTTInitialViewModel?
    @IBOutlet weak var createRoomButton: UIButton!
    @IBOutlet weak var joinRoomButton: UIButton!
    @IBOutlet weak var nickNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let textFieldSignal = self.nickNameTextField.rac_textSignal().toSignalProducer()
                                .flatMapError { error in
                                    return SignalProducer<AnyObject?, NoError>.empty
                                }
                                .map { text in
                                    Bool(text?.length > 3)
                                }
        DynamicProperty(object: self.createRoomButton, keyPath: "enabled") <~ textFieldSignal
        DynamicProperty(object: self.joinRoomButton, keyPath: "enabled") <~ textFieldSignal
    }
    
    @IBAction func didTapJoinRoom(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(self.nickNameTextField.text, forKey: Keys.Nickname)
        print("Join")
    }
    
    @IBAction func didTapCreateRoom(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(self.nickNameTextField.text, forKey: Keys.Nickname)
        self.viewModel?.createRoom()
        self.performSegueWithIdentifier("PresentCreatedRoom", sender: self)
    }

}

