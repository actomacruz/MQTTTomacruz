//
//  MQTTConstants.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 16/08/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import Foundation

enum MessageDefaults {
    static let TopicRoot = "/codenames-real"
    static let LastWillMessage = "Goodbye"
    static let CreateRoomMessage = "Room Created"
    static let KickRoomMessage = "Room Deleted"
    static let LeaveRoomMessage = "Has Left"
    static let JoinRoomMessage = "Joined Room"
}

enum Keys {
    static let Nickname = "nickname"
}