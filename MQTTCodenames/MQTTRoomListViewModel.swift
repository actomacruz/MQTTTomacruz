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
    
    var roomListArray: MutableProperty<[String]>
    private var mqttManager: MQTTManager?
    
    init(manager: MQTTManager?) {
        mqttManager = manager
        roomListArray = MutableProperty<[String]>([String]())
        mqttManager?.messageSignal.observeNext { next in
            if (next.hasPrefix(MessageDefaults.CreateRoomMessage)) {
                self.roomListArray.value.append(next)
            }
        }
        mqttManager?.subscribe(MessageDefaults.TopicRoot + "/+")
    }
    
    func unsubscribe() {
        mqttManager?.unsubscribe(MessageDefaults.TopicRoot + "/+")
    }
    
    func roomViewModel(selectedRoom: Int, roomCreator: Bool) -> MQTTRoomViewModel {
        let roomName: String? = roomListArray.value[selectedRoom]
        let topic = MessageDefaults.TopicRoot + "/" + (roomName?.componentsSeparatedByString(" - ")[1])!
        return MQTTRoomViewModel.init(topic: topic, manager: mqttManager, creator: roomCreator)
    }
    
}