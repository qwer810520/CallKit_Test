//
//  Call.swift
//  iGas
//
//  Created by 張楷岷 on 2017/10/12.
//  Copyright © 2017年 GLN. All rights reserved.
//

import Foundation

final class Call {
    
    let uuid: UUID
    let isOutgoing: Bool
    var handle: String?
    
    var connectionDate: Date? {
        didSet {
            stateDidChange?()
            hasStartedConnectingDidChange?()
        }
    }
    
    var connectDate: Date? {
        didSet {
            stateDidChange?()
            hasConnectedDidChange?()
        }
    }
    
    var endDate: Date? {
        didSet {
            stateDidChange?()
            hasEndedDidChange?()
        }
    }
    
    var isOnHold = false {
        didSet {
            stateDidChange?()
        }
    }
    
    var stateDidChange: (() -> Void)?
    var hasStartedConnectingDidChange: (() -> Void)?
    var hasConnectedDidChange: (() -> Void)?
    var hasEndedDidChange: (() -> Void)?
    
    var hasStartedConnection: Bool {
        get {
            return connectDate != nil
        }
        set {
            connectDate = newValue ? Date() : nil
        }
    }
    
    var hasConnected: Bool {
        get {
            return connectDate != nil
        }
        set {
            connectDate = newValue ? Date() : nil
        }
    }
    
    var hasEnded: Bool {
        get {
            return endDate != nil
        }
        set {
            endDate = newValue ? Date() : nil
        }
    }
    
    var duration: TimeInterval {
        guard let connectDate = connectDate else {
            return 0
        }
        return Date().timeIntervalSince(connectDate)
    }
    
    init(uuid: UUID, isOutgoing: Bool = false) {
        self.uuid = uuid
        self.isOutgoing = isOutgoing
    }
    
    //TODO
    func startCall(complection: ((Bool) -> Void)?) {
        complection?(true)
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 3) {
            self.hasStartedConnection = true
            DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 1.5, execute: {
                self.hasConnected = true
            })
        }
    }
    
    func answerCall() {
        hasConnected = true
    }
    
    func endCall() {
        hasEnded = true
    }
    
    
}
