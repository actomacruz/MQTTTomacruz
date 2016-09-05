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

class MQTTRoomViewModel: MessageModelPropagateProtocol {
    
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
        mqttManager?.messageSignal.observeNext { [weak self] next in
            guard let weakSelf = self else {
                return
            }
            if (!(next.hasPrefix(MessageDefaults.CreateRoomMessage) || next.hasPrefix(MessageDefaults.KickRoomMessage) || next.hasPrefix(MessageDefaults.RoleAssignMessage) || next.hasPrefix(MessageDefaults.StartGameMessage))) {
                if (next.rangeOfString(MessageDefaults.JoinRoomMessage) != nil) {
                    let clientId = next.componentsSeparatedByString(" with ID ")[1]
                    weakSelf.playerIdArray.value.append(clientId)
                }
                else if (next.rangeOfString(MessageDefaults.LeaveRoomMessage) != nil) {
                    let clientId = next.componentsSeparatedByString(" with ID ")[1]
                    weakSelf.playerIdArray.value.removeAtIndex(weakSelf.playerIdArray.value.indexOf(clientId)!)
                }
                weakSelf.modelObserver.sendNext(next)
            }
            else if (next.hasPrefix(MessageDefaults.KickRoomMessage)) {
                weakSelf.mqttManager?.unsubscribe(weakSelf.createdOrJoinedTopic!)
                weakSelf.modelObserver.sendInterrupted()
            }
            else if (next.hasPrefix(MessageDefaults.RoleAssignMessage)) {
                let messageClientID = next.componentsSeparatedByString(" - ")[1]
                if (messageClientID == weakSelf.mqttManager?.clientIdPid) {
                    let messageTeam = next.componentsSeparatedByString(" - ")[2]
                    let messageRole = next.componentsSeparatedByString(" - ")[3]
                    if (messageTeam == "Red") {
                        weakSelf.assignedTeam = Team.Red
                    }
                    else {
                        weakSelf.assignedTeam = Team.Blue
                    }
                    if (messageRole == "Describer") {
                        weakSelf.assignedRole = Role.Describer
                    }
                    else {
                        weakSelf.assignedRole = Role.Guesser
                    }
                }
            }
            else if (next.hasPrefix(MessageDefaults.StartGameMessage)) {
                weakSelf.modelObserver.sendCompleted()
            }
        }
        mqttManager?.subscribeSignal.observeNext { [weak self] next in
            guard let weakSelf = self else {
                return
            }
            if (next) {
                weakSelf.mqttManager?.publish(weakSelf.createdOrJoinedTopic!, message: weakSelf.nickname! + " " + MessageDefaults.JoinRoomMessage + " with ID " + weakSelf.mqttManager!.clientIdPid)
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
            mqttManager?.publish(topic, message: name + " " + MessageDefaults.LeaveRoomMessage + " with ID " + mqttManager!.clientIdPid)
        }
        mqttManager?.unsubscribe(topic)
    }
    
    func startGame() {
        let secondTeamIndex = (playerIdArray.value.count / 2)
        for (index, playerID) in playerIdArray.value.enumerate() {
            var team = "Red"
            var role = "Guesser"
            if (index == 0 || index == secondTeamIndex) {
                role = "Describer"
            }
            if (index >= secondTeamIndex) {
                team = "Blue"
            }
            let message = MessageDefaults.RoleAssignMessage + " - " + playerID + " - " + team + " - " + role
            mqttManager?.publish(createdOrJoinedTopic!, message: message)
        }
        mqttManager?.publish(createdOrJoinedTopic!, message: "", retained: true)
        mqttManager?.publish(createdOrJoinedTopic!, message: MessageDefaults.StartGameMessage)
    }
    
    func roomName() -> String? {
        return createdOrJoinedTopic!.componentsSeparatedByString("CocoaMQTT-")[1]
    }
    
    func gameRoomViewModel() -> MQTTGameRoomViewModel? {
        return  MQTTGameRoomViewModel.init(topic: self.createdOrJoinedTopic, manager: mqttManager, randomTeam: assignedTeam!, randomRole: assignedRole!)
    }
    
}