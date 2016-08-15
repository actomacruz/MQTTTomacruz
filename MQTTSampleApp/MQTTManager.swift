//
//  MQTTManager.swift
//  MQTTSampleApp
//
//  Created by Arvin John Tomacruz on 16/08/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import Foundation
import CocoaMQTT

class MQTTManager {

    init () {
        let clientIdPid = "CocoaMQTT-" + String(NSProcessInfo().processIdentifier)
        let mqtt = CocoaMQTT(clientId: clientIdPid, host: "api.brandx.dev.voyager.ph", port: 1883)
        mqtt.username = "actomacruz"
        mqtt.password = "Password1"
        //mqtt.willMessage = CocoaMQTTWill(topic: "/codenames", message: "welcome")
        mqtt.keepAlive = 90
        mqtt.secureMQTT = true
        mqtt.delegate = self
        mqtt.connect()
    }
    
}

extension MQTTManager: CocoaMQTTDelegate {
    
    func mqtt(mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("didConnect \(host):\(port)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("didConnectAck \(ack.rawValue)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage with message: \(message.string)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck with id: \(id)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        guard message.string != nil else {
            print("didReceivedMessage: NOT STRING with id \(id)")
            return
        }
        print("didReceivedMessage: \(message.string) with id \(id)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("didSubscribeTopic to \(topic)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic to \(topic)")
    }
    
    func mqttDidPing(mqtt: CocoaMQTT) {
        print("didPing")
    }
    
    func mqttDidReceivePong(mqtt: CocoaMQTT) {
        print("didReceivePong")
    }
    
    func mqttDidDisconnect(mqtt: CocoaMQTT, withError err: NSError?) {
        print("mqttDidDisconnect")
    }
    
}