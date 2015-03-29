//
//  File.swift
//  catchRun
//
//  Created by Ji Pei on 12/16/14.
//  Copyright (c) 2014 LUSS. All rights reserved.
//

import Foundation

class AudioController : NSObject, AVAudioPlayerDelegate {
    var audioSession : AVAudioSession?
    var backgroundMusicPlayer : AVAudioPlayer?
    var backgroundMusicPlaying : Bool = false
    var backgroundMusicInterrupted : Bool = false
    
     override init(){
        super.init()
        configureSession()
        configurePlayer()
    }
    
    func configureSession(){
        //AVAudioSession init
        audioSession = AVAudioSession.sharedInstance()
        audioSession!.setCategory(AVAudioSessionCategoryAmbient, error: nil)
    }
    
    func configurePlayer(){
        var error = NSErrorPointer();
        let path = NSBundle.mainBundle().pathForResource("bgm", ofType: "mp3")
        let url:NSURL! = NSURL.fileURLWithPath(path!)
        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: url, error: error)
        backgroundMusicPlayer!.delegate = self
        backgroundMusicPlayer!.numberOfLoops = -1
    }
    
    func tryPlayMusic(){
        if backgroundMusicPlaying || audioSession!.otherAudioPlaying {
            return
        }
        
        backgroundMusicPlaying = true
        backgroundMusicPlayer!.prepareToPlay()
        backgroundMusicPlayer!.play()
    }
    
    func stopMusic(){
        if !backgroundMusicPlaying && !audioSession!.otherAudioPlaying{
            return
        }
        
        backgroundMusicPlaying = false
        backgroundMusicPlayer!.stop()
    }
    
    //MARK : AVAudioPlayerDelegate
    func audioPlayerBeginInterruption(player: AVAudioPlayer!) {
        backgroundMusicInterrupted = true
        backgroundMusicPlaying = true
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer!) {
        tryPlayMusic()
        backgroundMusicInterrupted = false
    }
    
}