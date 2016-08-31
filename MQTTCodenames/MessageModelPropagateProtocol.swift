//
//  MessageSignalProtocol.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 01/09/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa
import enum Result.NoError

protocol MessageModelPropagateProtocol {
    
    var modelSignal: Signal<String, NoError> { get }
    var modelObserver: Observer<String, NoError> { get }
    
}