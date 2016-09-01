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
    private let createdTopic: String?
    
    init(manager: MQTTManager?) {
        mqttManager = manager
        guard let clientIdPiD = mqttManager?.clientIdPid else {
            createdTopic = MessageDefaults.TopicRoot
            return
        }
        createdTopic = MessageDefaults.TopicRoot + "/" + clientIdPiD
    }
    
    func createRoom() {
        mqttManager?.publish(createdTopic!, message: MessageDefaults.CreateRoomMessage + " - " + mqttManager!.clientIdPid, retained: true)
    }
    
    func roomViewModel(roomCreator: Bool) -> MQTTRoomViewModel {
        return MQTTRoomViewModel.init(topic: createdTopic, manager: mqttManager, creator: roomCreator)
    }
    
    func roomListViewModel() -> MQTTRoomListViewModel {
        return MQTTRoomListViewModel.init(manager: mqttManager)
    }
    
}