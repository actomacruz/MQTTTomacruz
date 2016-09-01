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

class MQTTGameRoomViewModel: MessageModelPropagateProtocol {

    var points: MutableProperty<Int>
    var turn: MutableProperty<Bool>
    
    private var team: Team
    private var role: Role
    private let nickname: String?
    private let gameTopic: String?
    private var mqttManager: MQTTManager?
    private var puzzleModel: MQTTPuzzleModel
    private let pattern = SampleData.samplePattern
    private let word = SampleData.wordList
    private var currentTurn: (team: Team, role: Role)
    
    var modelSignal: Signal<String, NoError>
    var modelObserver: Observer<String, NoError>
    
    init(topic: String?, manager: MQTTManager?, randomTeam: Team, randomRole: Role) {
        gameTopic = topic
        mqttManager = manager
        team = randomTeam
        role = randomRole
        points = MutableProperty<Int>(0)
        turn = MutableProperty<Bool>(false)
        
        let firstTurn = pattern["firstTurn"] as! Int
        if (firstTurn == Team.Red.rawValue) {
            currentTurn = (Team.Red , Role.Describer)
        }
        else {
            currentTurn = (Team.Blue , Role.Describer)
        }
        
        puzzleModel = MQTTPuzzleModel.init(blueTeam: (pattern["blueTeam"] as! [Int]), redTeam: (pattern["redTeam"] as! [Int]), black: (pattern["blackSpot"] as! Int))
        nickname = NSUserDefaults.standardUserDefaults().objectForKey(Keys.Nickname) as? String
        (modelSignal, modelObserver) = Signal<String, NoError>.pipe()
        
        mqttManager?.messageSignal.observeNext { [weak self] next in
            guard let weakSelf = self else {
                return
            }
            if (!next.hasPrefix(MessageDefaults.SwitchTurnMessage)) {
                weakSelf.modelObserver.sendNext(next)
            }
            else if (next.hasPrefix(MessageDefaults.SwitchTurnMessage)) {
                let teamText = next.componentsSeparatedByString(" - ")[1]
                let roleText = next.componentsSeparatedByString(" - ")[2]
                var currentTeam = Team.Red
                if teamText == "Blue" {
                    currentTeam = Team.Blue
                }
                var currentRole = Role.Describer
                if roleText == "Guesser" {
                    currentRole = Role.Guesser
                }
                weakSelf.currentTurn = (currentTeam, currentRole)
                if (weakSelf.isMyTurn()) {
                    weakSelf.turn = MutableProperty<Bool>(true)
                }
                else {
                    weakSelf.turn = MutableProperty<Bool>(false)
                }
            }
        }
    }
    
    func determineFirstTurn() {
        let firstTurn = pattern["firstTurn"] as! Int
        if (firstTurn == team.rawValue && role == Role.Describer) {
            turn = MutableProperty<Bool>(true)
            mqttManager?.publish(gameTopic!, message: nickname! + " turn to Describe")
        }
        else {
            turn = MutableProperty<Bool>(false)
        }
    }
    
    func switchTurn() {
        if (currentTurn.role == Role.Describer) {
            currentTurn = (currentTurn.team, Role.Guesser)
        }
        else {
            if (currentTurn.team == Team.Red) {
                currentTurn = (Team.Blue, Role.Describer)
            }
            else {
                currentTurn = (Team.Red, Role.Describer)
            }
        }
        var teamText = "Red"
        if (currentTurn.team == Team.Blue) {
            teamText = "Blue"
        }
        var roleText = "Describer"
        if (currentTurn.role == Role.Guesser) {
            roleText = "Guesser"
        }
        mqttManager?.publish(gameTopic!, message: MessageDefaults.SwitchTurnMessage + " - " + teamText + " - " + roleText)
    }
    
    private func isMyTurn() -> Bool {
        if currentTurn.team == team && currentTurn.role == role {
            if role == Role.Describer {
                mqttManager?.publish(gameTopic!, message: nickname! + " turn to Describe")
            }
            else {
                mqttManager?.publish(gameTopic!, message: nickname! + " turn to Guess")
            }
            return true
        }
        return false
    }
    
    func isDescriber() -> Bool {
        return (role == Role.Describer)
    }
    
    func nameDisplay() -> String {
        return nickname!
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
    
    func wordForIndex(index: Int) -> String {
        return word[index]
    }
    
    func wordAllowed(chosenWord: String) -> Bool {
        return !word.contains(chosenWord)
    }
    
    func publish(text: String) {
        if (role == Role.Describer) {
            mqttManager?.publish(gameTopic!, message: nickname! + " describes " + text)
        }
        else {
            mqttManager?.publish(gameTopic!, message: nickname! + " says " + text)
        }
    }
    
}