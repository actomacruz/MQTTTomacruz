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

enum TeamHit: Int {
    case Blue = 0
    case Red
    case Black
    case NoTeam
}

struct SampleData {
    
    var wordList = ["Penguin", "Cycle", "Iron", "Knife", "Ball",
                    "Moscow", "Laser", "Pole", "Missile", "Dinosaur",
                    "Jack", "China", "Knight", "Dice", "Track",
                    "Calf", "Mine", "Shadow", "Shop", "Cook",
                    "Chick", "Gas", "Wake", "Nail", "Scorpion"]
    
    var samplePattern = [
                            "image": "pattern_1",
                            "redTeam": [1, 4, 9, 10, 16, 17, 19, 21, 24],
                            "blueTeam": [2, 3, 6, 8, 14, 15, 22, 25],
                            "blackSpot": 12
                        ]
    
}