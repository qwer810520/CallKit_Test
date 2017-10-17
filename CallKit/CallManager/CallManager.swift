//
//  CallManager.swift
//  iGas
//
//  Created by 張楷岷 on 2017/10/12.
//  Copyright © 2017年 GLN. All rights reserved.
//

import UIKit
import CallKit

@available(iOS 10.0, *)
final class CallManager: NSObject {
    
    fileprivate let callController = CXCallController()
    static let callChangedNotification = Notification.Name("CallManagerCallChangedNotification")
    private(set) var calls = [Call]()
    
    func startCall(handle: String, video: Bool = false) {
        let startCallAction = CXStartCallAction(call: UUID(), handle: CXHandle(type: .generic, value: handle))
        startCallAction.isVideo = video
        
        transactionAddAction(action: startCallAction)
    }
    
    func end(call: Call) {
        let endCallAction = CXEndCallAction(call: call.uuid)
        transactionAddAction(action: endCallAction)
    }
    
    func setHeld(call: Call, onHold: Bool) {
        let setHeldCallAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
        transactionAddAction(action: setHeldCallAction)
    }
    
    func callWithUUID(uuid: UUID) -> Call? {
        guard let index = calls.index(where: { $0.uuid == uuid }) else {
            return nil
        }
        return calls[index]
    }
    
    func addCall(call: Call) {
        calls.append(call)
        call.stateDidChange = { [weak self] in
            self?.postCallsChangeNotification()
        }
        postCallsChangeNotification()
    }
    
    func removeCall(call: Call) {
        calls.removeFirst(where: { $0 === call })
        postCallsChangeNotification()
    }
    
    func removeAllCalls() {
        calls.removeAll()
        postCallsChangeNotification()
    }
    
    func callDidChangeState(call: Call) {
        postCallsChangeNotification()
    }
    
    private func postCallsChangeNotification() {
        NotificationCenter.default.post(name: type(of: self).callChangedNotification, object: self)
    }
    
    private func transactionAddAction(action: CXAction) {
        let transaction = CXTransaction()
        transaction.addAction(action)
        callController.request(transaction) { (error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                print("=====沒有錯誤=====")
            }
        }
    }
}

extension Array {
    mutating func removeFirst(where predicate: (Element)throws -> Bool) rethrows {
        guard let index = try index(where: predicate) else {
            return
        }
        remove(at: index)
    }
}



