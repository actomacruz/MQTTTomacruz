//
//  MQTTGameRoomViewController.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 01/09/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import UIKit

class MQTTGameRoomViewController: UIViewController {

    var viewModel: MQTTGameRoomViewModel?
    var buttonArray: [UIButton]?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    
    @IBOutlet weak var patternImageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonArray = [UIButton]()
        nicknameLabel.text = "Hi " + self.viewModel!.nameDisplay()
        teamLabel.text = "Team: " + self.viewModel!.teamName()
        if (self.viewModel!.willShowPattern()) {
            self.patternImageView.image = UIImage.init(named: (self.viewModel?.patternImageName())!)
        }
        else {
            self.patternImageView.hidden = true
            self.slider.hidden = true
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(aNotification: NSNotification) {
        let keyboardSize = aNotification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size
        let contentInsets = UIEdgeInsetsMake(self.scrollView.contentInset.top, 0.0, (keyboardSize?.height)! + 10.0, 0.0)
        self.scrollView.contentInset = contentInsets;
    }
    
    func keyboardWillHide(aNotification: NSNotification) {
        let contentInsets = UIEdgeInsetsMake(self.scrollView.contentInset.top, 0.0, 0.0, 0.0)
        self.scrollView.contentInset = contentInsets;
    }

}