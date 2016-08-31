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
    
    func createRoom() {
        let createdTopic = MessageDefaults.TopicRoot + "/" + mqttManager!.clientIdPid
        self.mqttManager?.publish(createdTopic, message: MessageDefaults.CreateRoomMessage)
    }
    
    func joinRoom() {
        
    }
    
}