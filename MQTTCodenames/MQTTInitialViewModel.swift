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
    private let nickname: String?
    private let createdTopic: String?
    
    init(manager: MQTTManager?) {
        mqttManager = manager
        nickname = NSUserDefaults.standardUserDefaults().objectForKey(Keys.Nickname) as? String
        guard let clientIdPiD = mqttManager?.clientIdPid else {
            createdTopic = MessageDefaults.TopicRoot
            return
        }
        createdTopic = MessageDefaults.TopicRoot + "/" + clientIdPiD
    }
    
    func createRoom() {
        mqttManager?.publish(createdTopic!, message: MessageDefaults.CreateRoomMessage + " - " + mqttManager!.clientIdPid, retained: true)
        mqttManager?.subscribe(createdTopic!)
        mqttManager?.publish(createdTopic!, message: nickname! + " " + MessageDefaults.JoinRoomMessage)
    }
    
    func joinRoom() {
        
    }
    
    func roomViewModel() -> MQTTRoomViewModel {
        var roomViewModel = MQTTRoomViewModel.init(topic: createdTopic)
        roomViewModel.mqttManager = mqttManager
        return roomViewModel
    }
    
    func roomListViewModel() -> MQTTRoomListViewModel {
        return MQTTRoomListViewModel.init(manager: mqttManager)
    }
    
}