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
    
    var roomCreator: Bool
    var mqttManager: MQTTManager?
    var playerCount: MutableProperty<Int>
    
    private let nickname: String?
    private let createdOrJoinedTopic: String?
    
    var modelSignal: Signal<String, NoError>
    var modelObserver: Observer<String, NoError>
    
    init(topic: String?, manager: MQTTManager?, creator: Bool) {
        createdOrJoinedTopic = topic
        mqttManager = manager
        roomCreator = creator
        playerCount = MutableProperty<Int>(0)
        nickname = NSUserDefaults.standardUserDefaults().objectForKey(Keys.Nickname) as? String
        (modelSignal, modelObserver) = Signal<String, NoError>.pipe()
        mqttManager?.messageSignal.observeNext { next in
            if (!(next.hasPrefix(MessageDefaults.CreateRoomMessage) || next.hasPrefix(MessageDefaults.KickRoomMessage))) {
                if (next.hasSuffix(MessageDefaults.JoinRoomMessage)) {
                    self.playerCount.value = self.playerCount.value + 1
                }
                else if (next.hasSuffix(MessageDefaults.LeaveRoomMessage)) {
                    self.playerCount.value = self.playerCount.value - 1
                }
                self.modelObserver.sendNext(next)
            }
            else if (next.hasPrefix(MessageDefaults.KickRoomMessage)) {
                self.mqttManager?.unsubscribe(self.createdOrJoinedTopic!)
                self.modelObserver.sendInterrupted()
            }
        }
        mqttManager?.subscribeSignal.observeNext { next in
            if (next) {
                self.mqttManager?.publish(self.createdOrJoinedTopic!, message: self.nickname! + " " + MessageDefaults.JoinRoomMessage)
            }
        }
        mqttManager?.subscribe(createdOrJoinedTopic!)
    }
    
    func leaveRoom() {
        guard let topic = createdOrJoinedTopic, let name = nickname else {
            return
        }
        if (roomCreator) {
            mqttManager?.publish(topic, message: MessageDefaults.KickRoomMessage)
            mqttManager?.publish(topic, message: "", retained: true)
        }
        else {
            mqttManager?.publish(topic, message: name + " " + MessageDefaults.LeaveRoomMessage)
        }
        mqttManager?.unsubscribe(topic)
    }
    
    func roomName() -> String? {
        return mqttManager?.clientIdPid.componentsSeparatedByString("-")[1]
    }
    
}