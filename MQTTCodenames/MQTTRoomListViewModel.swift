//
//  MQTTRoomListViewModel.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 01/09/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa

class MQTTRoomListViewModel : NSObject {
    
    var mqttManager: MQTTManager?
    var roomListArray = NSMutableArray()
    
    init(manager: MQTTManager?) {
        super.init()
        mqttManager = manager
        mqttManager?.subscribe(MessageDefaults.TopicRoot + "/+")
        mqttManager?.messageSignal.observeNext { [unowned self] next in
            if (next.hasPrefix(MessageDefaults.CreateRoomMessage)) {
                self.roomListArray.addObject(next)
            }
        }
    }
    
}