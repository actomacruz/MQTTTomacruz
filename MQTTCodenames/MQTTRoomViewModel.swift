//
//  MQTTRoomViewModel.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 31/08/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import Foundation

struct MQTTRoomViewModel {
    
    var mqttManager: MQTTManager?
    private let createdTopic: String?
    
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
    
    func roomName() -> String? {
        return mqttManager?.clientIdPid.componentsSeparatedByString("-")[1]
    }
    
}