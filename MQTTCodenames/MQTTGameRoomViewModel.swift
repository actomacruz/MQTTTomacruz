//
//  MQTTGameRoomViewModel.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 02/09/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa
import enum Result.NoError

struct MQTTGameRoomViewModel {

    var points: MutableProperty<Int>
    var turn: MutableProperty<Bool>
    var describer: MutableProperty<Bool>
    
    private var team: Team
    private var role: Role
    private let nickname: String?
    private let gameTopic: String?
    private var mqttManager: MQTTManager?
    private var puzzleModel: MQTTPuzzleModel
    private let pattern = SampleData.samplePattern
    private let word = SampleData.wordList
    
    init(topic: String?, manager: MQTTManager?, randomTeam: Team, randomRole: Role) {
        gameTopic = topic
        mqttManager = manager
        team = randomTeam
        role = randomRole
        points = MutableProperty<Int>(0)
        let firstTurn = pattern["firstTurn"] as! Int
        if (firstTurn == team.rawValue) {
            turn = MutableProperty<Bool>(true)
        }
        else {
            turn = MutableProperty<Bool>(false)
        }
        describer = MutableProperty<Bool>(true)
        puzzleModel = MQTTPuzzleModel.init(blueTeam: (pattern["blueTeam"] as! [Int]), redTeam: (pattern["redTeam"] as! [Int]), black: (pattern["blackSpot"] as! Int))
        nickname = NSUserDefaults.standardUserDefaults().objectForKey(Keys.Nickname) as? String
    }
    
    func patternImageName() -> String {
        return (pattern["image"] as! String)
    }
    
    func willShowPattern() -> Bool {
        return (role == Role.Describer)
    }
    
    func teamName() -> String {
        if (team == Team.Blue) {
            return "Blue"
        }
        else {
            return "Red"
        }
    }
    
    func wordList() -> [String] {
        return word
    }
    
}