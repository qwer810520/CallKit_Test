//
//  ProviderDelegate.swift
//  iGas
//
//  Created by 張楷岷 on 2017/9/28.
//  Copyright © 2017年 GLN. All rights reserved.
//

import UIKit
import CallKit
import AVFoundation

@available(iOS 10.0, *)
class ProviderDelegate: NSObject {
    
    let callManager: CallManager
    let callAudio =  CallAudio()
    var audioPlayer: AVAudioPlayer!
    //負責來電
    fileprivate let provider: CXProvider
    
    init(callManager: CallManager) {
        self.callManager = callManager
        provider = CXProvider(configuration: type(of: self).providerConfiguration)
        super.init()
        provider.setDelegate(self, queue: nil)
    }
    
    static var providerConfiguration: CXProviderConfiguration {
        //來電時顯示的文字
        let providerConfigurtion = CXProviderConfiguration(localizedName: "樂享退能源")
        //開啟視訊通話的選項
        providerConfigurtion.supportsVideo = false 
        //每個呼叫組最大數量
        providerConfigurtion.maximumCallsPerCallGroup = 1
        //通話類型
        providerConfigurtion.supportedHandleTypes = [.phoneNumber, .generic, .emailAddress]
        
        //Icon圖片
        if let iconMask = UIImage(named: "iconbee"){
            providerConfigurtion.iconTemplateImageData = UIImageJPEGRepresentation(iconMask, 1.0)
        }
        //提供鈴聲的
//        providerConfigurtion.ringtoneSound = "ringtone.wav"
        
        return providerConfigurtion
    }
    
    
//    func call(handle: String) {
//        let startCallAction = CXStartCallAction(call: UUID(), handle: CXHandle(type: .generic, value: handle))
//        transaction(action: startCallAction) { (error) in
//            print(error)
//        }
//
//    }
//
//    func endcall(uuids: [UUID], complection: (UUID) -> Void) {
//        let uuid = uuids.first
//        let action = CXEndCallAction(call: uuid!)
//        transaction(action: action) { (error) in
//            print(error)
//        }
//    }
//
//    private func transaction(action: CXAction, complection: @escaping (Error?) -> Void) {
//        let transaction = CXTransaction()
//        transaction.addAction(action)
//        callController.request(transaction) { (error) in
//            complection(error)
//        }
//    }
    
    func reportIncomingCall(uuid: UUID, handle: String, complection: ((Error?) -> Void)? = nil) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: handle)
        update.hasVideo = false
        provider.reportNewIncomingCall(with: uuid, update: update) { (error) in
            if error != nil {
                complection!(error)
            } else {
                let call = Call(uuid: uuid)
                call.handle = handle
                self.callManager.addCall(call: call)
            }
        }
    }
}

    //MARK: CXProviderDelegate
@available(iOS 10.0, *)
extension ProviderDelegate: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        callAudio.stopAudio()
        
        for call in callManager.calls {
            call.endCall()
        }
        callManager.removeAllCalls()
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        let call = Call(uuid: action.uuid, isOutgoing: true)
        call.handle = action.handle.value
        
        callAudio.configureAudioSession()
        
        call.hasStartedConnectingDidChange = { [weak self] in
            self?.provider.reportOutgoingCall(with: call.uuid, connectedAt: call.connectDate)
        }
        
        call.hasConnectedDidChange = { [weak self] in
            self?.provider.reportOutgoingCall(with: call.uuid, connectedAt: call.connectDate)
        }
        
        call.startCall { (success) in
            if success {
                action.fulfill()
                self.callManager.addCall(call: call)
            } else {
                action.fail()
            }
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        //接聽會做的事情
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }

        
        call.answerCall()
        callAudio.configureAudioSession()
        callAudio.playAudio()
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        callAudio.stopAudio()
        call.endCall()
        action.fulfill()
        callManager.removeCall(call: call)


    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        call.isOnHold = action.isOnHold
        
        if call.isOnHold {
            callAudio.stopAudio()
        } else {
            callAudio.startAudio()
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        print(#function)
//        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print(#function)
        callAudio.startAudio()
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print(#function)
    }
}
