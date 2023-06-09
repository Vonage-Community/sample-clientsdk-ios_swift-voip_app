//
//  UserController.swift
//  VonageSDKClientVOIPExample
//
//  Created by Ashley Arthur on 25/01/2023.
//

import Foundation
import Combine
 
typealias UserToken = String

enum UserControllerErrors:Error {
    case InvalidCredentials
    case unknown
}

class UserController: NSObject {
    
    var user =  CurrentValueSubject<(User,UserToken)?,UserControllerErrors>(nil)
    var token = ""
    
    func login(username:String, pword:String) {
        
        // Dummy Implementation for testing purposes
        user.send((User(uname: "user1"), token))
    }
    
    func restoreUser() {
        // Dummy Implementation for testing purposes
        user.send((User(uname: "user1"), token))
    }
    
}

