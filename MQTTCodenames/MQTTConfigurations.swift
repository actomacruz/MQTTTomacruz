//
//  MQTTConfigurations.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 24/08/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import Foundation
import VoyagerGenericEncryptionSDK

enum Broker {
    static let Host = VGEncryptor.sharedInstance().getDecryptedDataWithKey("Host")
    static let Port = VGEncryptor.sharedInstance().getDecryptedDataWithKey("Port")
}

enum Account {
    static let Username = VGEncryptor.sharedInstance().getDecryptedDataWithKey("Username")
    static let Password = VGEncryptor.sharedInstance().getDecryptedDataWithKey("Password")
}