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
    private let nickname: String?
    private let createdTopic: String?
    
    var modelSignal: Signal<String, NoError>
    var modelObserver: Observer<String, NoError>
    
    init(topic: String?, manager: MQTTManager?) {
        createdTopic = topic
        mqttManager = manager
        nickname = NSUserDefaults.standardUserDefaults().objectForKey(Keys.Nickname) as? String
        (modelSignal, modelObserver) = Signal<String, NoError>.pipe()
        mqttManager?.subscribe(createdTopic!)
        mqttManager?.messageSignal.observeNext { next in
            if (!(next.hasPrefix(MessageDefaults.CreateRoomMessage) || next.hasPrefix(MessageDefaults.KickRoomMessage))) {
                self.modelObserver.sendNext(next)
            }
        }
        mqttManager?.subscribeSignal.observeNext { next in
            if (next) {
                self.mqttManager?.publish(self.createdTopic!, message: self.nickname! + " " + MessageDefaults.JoinRoomMessage)
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