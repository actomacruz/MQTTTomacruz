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
    var playerIdArray: MutableProperty<[String]>
    
    private let nickname: String?
    private var mqttManager: MQTTManager?
    private let createdOrJoinedTopic: String?
    private var assignedRole: Role?
    private var assignedTeam: Team?
    
    var modelSignal: Signal<String, NoError>
    var modelObserver: Observer<String, NoError>
    
    init(topic: String?, manager: MQTTManager?, creator: Bool) {
        createdOrJoinedTopic = topic
        mqttManager = manager
        roomCreator = creator
        playerIdArray = MutableProperty<[String]>([String]())
        nickname = NSUserDefaults.standardUserDefaults().objectForKey(Keys.Nickname) as? String
        (modelSignal, modelObserver) = Signal<String, NoError>.pipe()
        mqttManager?.messageSignal.observeNext { next in
            if (!(next.hasPrefix(MessageDefaults.CreateRoomMessage) || next.hasPrefix(MessageDefaults.KickRoomMessage) || next.hasPrefix(MessageDefaults.RoleAssignMessage) || next.hasPrefix(MessageDefaults.StartGameMessage))) {
                if (next.rangeOfString(MessageDefaults.JoinRoomMessage) != nil) {
                    let clientId = next.componentsSeparatedByString(" with ID ")[1]
                    self.playerIdArray.value.append(clientId)
                }
                else if (next.rangeOfString(MessageDefaults.LeaveRoomMessage) != nil) {
                    let clientId = next.componentsSeparatedByString(" with ID ")[1]
                    self.playerIdArray.value.removeAtIndex(self.playerIdArray.value.indexOf(clientId)!)
                }
                self.modelObserver.sendNext(next)
            }
            else if (next.hasPrefix(MessageDefaults.KickRoomMessage)) {
                self.mqttManager?.unsubscribe(self.createdOrJoinedTopic!)
                self.modelObserver.sendInterrupted()
            }
            else if (next.hasPrefix(MessageDefaults.RoleAssignMessage)) {
                let messageClientID = next.componentsSeparatedByString(" - ")[1]
                if (messageClientID == self.mqttManager?.clientIdPid) {
                    let messageTeam = next.componentsSeparatedByString(" - ")[2]
                    let messageRole = next.componentsSeparatedByString(" - ")[3]
                    if (messageTeam == "Red") {
                        self.assignedTeam = Team.Red
                    }
                    else {
                        self.assignedTeam = Team.Blue
                    }
                    if (messageRole == "Describer") {
                        self.assignedRole = Role.Describer
                    }
                    else {
                        self.assignedRole = Role.Guesser
                    }
                }
            }
            else if (next.hasPrefix(MessageDefaults.StartGameMessage)) {
                self.modelObserver.sendCompleted()
            }
        }
        mqttManager?.subscribeSignal.observeNext { next in
            if (next) {
                self.mqttManager?.publish(self.createdOrJoinedTopic!, message: self.nickname! + " " + MessageDefaults.JoinRoomMessage + " with ID " + self.mqttManager!.clientIdPid)
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
            mqttManager?.publish(topic, message: name + " " + MessageDefaults.LeaveRoomMessage + " with ID " + self.mqttManager!.clientIdPid)
        }
        mqttManager?.unsubscribe(topic)
    }
    
    func startGame() {
        let secondTeamIndex = (self.playerIdArray.value.count / 2)
        for (index, playerID) in self.playerIdArray.value.enumerate() {
            var team = "Red"
            var role = "Guesser"
            if (index == 0 || index == secondTeamIndex) {
                role = "Describer"
            }
            if (index >= secondTeamIndex) {
                team = "Blue"
            }
            let message = MessageDefaults.RoleAssignMessage + " - " + playerID + " - " + team + " - " + role
            self.mqttManager?.publish(self.createdOrJoinedTopic!, message: message)
        }
        self.mqttManager?.publish(self.createdOrJoinedTopic!, message: MessageDefaults.StartGameMessage)
    }
    
    func roomName() -> String? {
        return createdOrJoinedTopic!.componentsSeparatedByString("CocoaMQTT-")[1]
    }
    
    func gameRoomViewModel() -> MQTTGameRoomViewModel? {
        return  MQTTGameRoomViewModel.init(topic: self.createdOrJoinedTopic, manager: self.mqttManager, randomTeam: self.assignedTeam!, randomRole: self.assignedRole!)
    }
    
}