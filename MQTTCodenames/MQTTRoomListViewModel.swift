//
//  MQTTRoomListViewModel.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 01/09/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import Foundation

struct MQTTRoomListViewModel {
    
    var mqttManager: MQTTManager?
    
    init(manager: MQTTManager?) {
        mqttManager = manager
        mqttManager?.subscribe(MessageDefaults.TopicRoot + "/+")
    }
    
}