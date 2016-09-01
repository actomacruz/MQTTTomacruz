//
//  MQTTGameRoomViewController.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 01/09/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import UIKit
import ReactiveCocoa
import enum Result.NoError

class MQTTGameRoomViewController: UIViewController {

    var viewModel: MQTTGameRoomViewModel?
    var buttonArray: [UIButton]?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    
    @IBOutlet weak var patternImageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonArray = [UIButton]()
        for subview in self.buttonView.subviews {
            if subview.isKindOfClass(UIButton) {
                self.buttonArray?.append(subview as! UIButton)
            }
        }
        for button in self.buttonArray! {
            button.setTitle(self.viewModel?.wordForIndex(button.tag - 1), forState: UIControlState.Normal)
        }
        self.nicknameLabel.text = "Hi " + self.viewModel!.nameDisplay()
        self.teamLabel.text = "Team: " + self.viewModel!.teamName()
        if (self.viewModel!.willShowPattern()) {
            self.patternImageView.image = UIImage.init(named: (self.viewModel?.patternImageName())!)
        }
        else {
            self.patternImageView.hidden = true
            self.slider.hidden = true
        }
        
        self.viewModel?.modelSignal.observeNext { [weak self] next in
            guard let weakSelf = self else {
                return
            }
            weakSelf.textView.text = weakSelf.textView.text + "\n" + next
        }
        
        self.viewModel?.turn.signal.observeNext { [weak self] next in
            guard let weakSelf = self else {
                return
            }
            if (next) {
                weakSelf.buttonView.userInteractionEnabled = true
                weakSelf.submitButton.enabled = true
                weakSelf.textField.enabled = true
                weakSelf.slider.enabled = true
            }
            else {
                weakSelf.buttonView.userInteractionEnabled = false
                weakSelf.submitButton.enabled = false
                weakSelf.textField.enabled = false
                weakSelf.slider.enabled = false
            }
        }
        
        if (self.viewModel!.isDescriber()) {
            let textFieldSignal = self.textField.rac_textSignal().toSignalProducer()
                .flatMapError { error in
                    return SignalProducer<AnyObject?, NoError>.empty
                }
                .map { (text) -> Bool in
                    if let guardedText: String = text as? String {
                        return (guardedText.characters.count > 0 && guardedText.rangeOfCharacterFromSet(NSCharacterSet.whitespaceCharacterSet()) == nil && self.viewModel!.wordAllowed(guardedText))
                    }
                    return false
                }
            DynamicProperty(object: self.submitButton, keyPath: "enabled") <~ textFieldSignal
        }
        
        self.viewModel?.determineFirstTurn()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @IBAction func didTapSubmit(sender: AnyObject) {
        let sliderValue = round(self.slider.value)
        if (self.viewModel!.isDescriber()) {
            self.viewModel?.publish(self.textField.text! + " " + String(sliderValue))
            self.viewModel?.switchTurn()
        }
        else {
            self.viewModel?.publish(self.textField.text!)
        }
        self.textField.text = ""
    }
    
    @IBAction func didTapWordButton(sender: AnyObject) {
        print("Tap Button")
        if (!(self.viewModel!.isDescriber())) {
            // check number of chosen words
        }
        self.textField.text = ""
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