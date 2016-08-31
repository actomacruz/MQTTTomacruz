//
//  MQTTManager.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 16/08/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import Foundation
import CocoaMQTT

class MQTTManager {

    let clientIdPid: String
    private let mqtt: CocoaMQTT
    
    init () {
        clientIdPid = "CocoaMQTT-" + String(NSProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientId: clientIdPid, host: Broker.Host, port: UInt16(Broker.Port)!)
        mqtt.username = Account.Username
        mqtt.password = Account.Password
        mqtt.willMessage = CocoaMQTTWill(topic: MessageDefaults.TopicRoot, message: MessageDefaults.LastWillMessage)
        mqtt.keepAlive = 90
        mqtt.delegate = self
    }
    
    func connect() {
        mqtt.connect()
    }
    
    func publish(topic: String, message: String) {
        mqtt.publish(topic, withString: message)
    }
    
    func publish(topic: String, message: String, retained: Bool) {
        mqtt.publish(topic, withString: message, qos: CocoaMQTTQOS.QOS0, retained: retained, dup: false)
    }
    
    func subscribe(topic: String) {
        mqtt.subscribe(topic)
    }
    
    func unsubscribe(topic: String) {
        mqtt.unsubscribe(topic)
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