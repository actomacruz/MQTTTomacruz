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

class MQTTGameRoomViewController: UIViewController, UIAlertViewDelegate {

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
        self.submitButton.enabled = false
        
        self.viewModel?.modelSignal.observeNext { [weak self] next in
            guard let weakSelf = self else {
                return
            }
            if (next.hasPrefix(MessageDefaults.RemoveWordMessage)) {
                let index = Int(next.componentsSeparatedByString(" - ")[1])!
                _ = weakSelf.buttonArray?.filter {
                    if ($0.tag == index) {
                        $0.alpha = 0
                        $0.enabled = false
                        return true
                    }
                    return false
                }
            }
            else if (next.hasPrefix(MessageDefaults.WinnerMessage)) {
                let alertView = UIAlertView.init(title: "Winner", message: next, delegate: weakSelf, cancelButtonTitle: "OK")
                alertView.show()
            }
            else {
                weakSelf.textView.text = weakSelf.textView.text + "\n" + next
            }
        }
        
        self.viewModel?.turn.signal.observeNext { [weak self] next in
            guard let weakSelf = self else {
                return
            }
            if (next) {
                if (weakSelf.viewModel!.isDescriber()) {
                    weakSelf.enableOrDisableWordButton(false)
                }
                else {
                    weakSelf.enableOrDisableWordButton(true)
                }
                weakSelf.textField.enabled = true
                weakSelf.slider.enabled = true
                if (weakSelf.textField.text?.characters.count > 0) {
                    weakSelf.submitButton.enabled = true
                }
                else {
                    weakSelf.submitButton.enabled = false
                }
            }
            else {
                weakSelf.enableOrDisableWordButton(false)
                weakSelf.submitButton.enabled = false
                weakSelf.textField.enabled = false
                weakSelf.slider.enabled = false
            }
        }
        
        self.viewModel?.points.signal.observeNext { [weak self] next in
            guard let weakSelf = self else {
                return
            }
            weakSelf.pointLabel.text = "Points: " + String(next)
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
        else {
            let textFieldSignal = self.textField.rac_textSignal().toSignalProducer()
                .flatMapError { error in
                    return SignalProducer<AnyObject?, NoError>.empty
                }
                .map { text in
                    Bool(text?.length > 0)
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
        let sliderValue = Int(round(self.slider.value))
        if (self.viewModel!.isDescriber()) {
            self.viewModel?.publish(self.textField.text! + " " + String(sliderValue))
            self.viewModel?.switchTurn()
        }
        else {
            self.viewModel?.publish(self.textField.text!)
        }
        self.textField.text = ""
        self.submitButton.enabled = false
    }
    
    @IBAction func didTapWordButton(sender: AnyObject) {
        let button = sender as! UIButton
        self.viewModel?.chooseWord(button.tag)
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
    
    func enableOrDisableWordButton(willEnable: Bool) {
        if (willEnable) {
            for button in buttonArray! {
                button.enabled = true
            }
        }
        else {
            for button in buttonArray! {
                button.enabled = false
            }
        }
    }
    
    // Mark UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.performSegueWithIdentifier("UnwindSegueForGame", sender: self)
    }

}