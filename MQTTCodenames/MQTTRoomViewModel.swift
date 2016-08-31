//
//  MQTTRoomViewModel.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 31/08/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa
import enum Result.NoError

struct MQTTRoomViewModel: MessageModelPropagateProtocol {
    
    var mqttManager: MQTTManager?
    private let createdTopic: String?
    
    var modelSignal: Signal<String, NoError>
    var modelObserver: Observer<String, NoError>
    
    init(topic: String?) {
        createdTopic = topic
        (modelSignal, modelObserver) = Signal<String, NoError>.pipe()
        mqttManager?.messageSignal.observeNext { next in
            if (!(next.hasPrefix(MessageDefaults.CreateRoomMessage) || next.hasPrefix(MessageDefaults.KickRoomMessage))) {
                self.modelObserver.sendNext(next)
            }
        }
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