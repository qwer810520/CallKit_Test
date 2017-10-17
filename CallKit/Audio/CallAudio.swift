//
//  CallAudio.swift
//  iGas
//
//  Created by 張楷岷 on 2017/10/13.
//  Copyright © 2017年 GLN. All rights reserved.
//

import Foundation

class CallAudio {
    
    private var audioController: AudioController?
    private var audioPlayer: AVAudioPlayer!
    
    func configureAudioSession() {
        if audioController == nil {
            audioController = AudioController()
        }
    }
    
    func startAudio() {
        if audioController?.startIOUnit() == kAudioServicesNoError {
            audioController?.muteAudio = false
        } else {
            
        }
    }
    
    func stopAudio() {
        if audioController?.startIOUnit() != kAudioServicesNoError {
            
        }
    }
    
    func playAudio() {
        do {
            if let bundle = Bundle.main.path(forResource: "ringtone", ofType: "wav") {
                let alertSound = URL(fileURLWithPath: bundle)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
                try AVAudioSession.sharedInstance().setActive(true)
                try audioPlayer = AVAudioPlayer(contentsOf: alertSound)
                audioPlayer.numberOfLoops = -1
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            }
        } catch {
            print(error)
        }
    }

}






