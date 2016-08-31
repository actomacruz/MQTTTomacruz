//
//  MQTTRoomViewModel.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 31/08/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import Foundation

struct MQTTRoomViewModel {
    
    let createdTopic: String?
    var mqttManager: MQTTManager?
    
    init(topic: String?) {
        createdTopic = topic
    }
    
    func leaveRoom() {
        guard let topic = createdTopic else {
            return
        }
        mqttManager?.publish(topic, message: MessageDefaults.KickRoomMessage)
        mqttManager?.publish(topic, message: "", retained: true)
        mqttManager?.unsubscribe(topic)
    }
    
}