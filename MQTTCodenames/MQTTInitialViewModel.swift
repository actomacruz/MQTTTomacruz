//
//  MQTTInitialViewModel.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 31/08/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa

struct MQTTInitialViewModel {
    
    var mqttManager: MQTTManager?
    var createdTopic: String?
    
    mutating func createRoom() {
        createdTopic = MessageDefaults.TopicRoot + "/" + mqttManager!.clientIdPid
        mqttManager?.publish(createdTopic!, message: MessageDefaults.CreateRoomMessage, retained: true)
    }
    
    func joinRoom() {
        
    }
    
    func roomViewModel() -> MQTTRoomViewModel {
        return MQTTRoomViewModel.init(topic: createdTopic)
    }
    
}