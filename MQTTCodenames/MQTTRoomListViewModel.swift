//
//  MQTTRoomListViewModel.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 01/09/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa
import enum Result.NoError

struct MQTTRoomListViewModel: MessageModelPropagateProtocol {
    
    var mqttManager: MQTTManager?
    var roomListArray = NSMutableArray()
    
    var modelSignal: Signal<String, NoError>
    var modelObserver: Observer<String, NoError>
    
    init(manager: MQTTManager?) {
        mqttManager = manager
        (modelSignal, modelObserver) = Signal<String, NoError>.pipe()
        mqttManager?.subscribe(MessageDefaults.TopicRoot + "/+")
        mqttManager?.messageSignal.observeNext { next in
            if (next.hasPrefix(MessageDefaults.CreateRoomMessage)) {
                self.roomListArray.addObject(next)
                self.modelObserver.sendNext("")
            }
        }
    }
    
}