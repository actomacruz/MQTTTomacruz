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

struct MQTTRoomListViewModel {
    
    var mqttManager: MQTTManager?
    var roomListArray = NSMutableArray()
    
    var reloadSignal: Signal<Bool, NoError>
    var reloadObserver: Observer<Bool, NoError>
    
    init(manager: MQTTManager?) {
        mqttManager = manager
        (reloadSignal, reloadObserver) = Signal<Bool, NoError>.pipe()
        mqttManager?.subscribe(MessageDefaults.TopicRoot + "/+")
        mqttManager?.messageSignal.observeNext { next in
            if (next.hasPrefix(MessageDefaults.CreateRoomMessage)) {
                self.roomListArray.addObject(next)
                self.reloadObserver.sendNext(true)
            }
        }
    }
    
}