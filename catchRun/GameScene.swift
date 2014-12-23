//
//  GameScene.swift
//  catchRun
//
//  Created by Shihao Ji on 12/16/14.
//  Copyright (c) 2014 LUSS. All rights reserved.
//

import SpriteKit
import Social

protocol sceneDelegate{
    func didChangeSound()
}

class GameScene: SKScene, GADInterstitialDelegate {
    var myDelegate:sceneDelegate?
    var soundButton:GGButton?
    var soundOn:Bool?
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let background:SKSpriteNode = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        background.size = CGSize(width: self.size.width, height: self.size.height)
        addChild(background)
        
        let startGameButton: GGButton = GGButton(defaultButtonImage: "button1", activeButtonImage: "button2", buttonAction: startGameButtonDown)
        startGameButton.xScale = 0.3
        startGameButton.yScale = 0.3
        startGameButton.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5 )
        addChild(startGameButton)
        
        let twitterButton:GGButton = GGButton(defaultButtonImage: "twitter", activeButtonImage: "twitter", buttonAction: twitter)
        twitterButton.xScale = 0.3
        twitterButton.yScale = 0.3
        twitterButton.position = CGPoint(x: 100, y: 100)
        addChild(twitterButton)
        
        if let isSoundOn = soundOn {
            if isSoundOn == true{
                soundButton = GGButton(defaultButtonImage: "sound_on", activeButtonImage: "sound_on", buttonAction: didTapOnSound)
                soundButton!.xScale = 0.05
                soundButton!.yScale = 0.05
                soundButton!.position = CGPoint(x: 100, y: 50)
                addChild(soundButton!)
            }else{
                soundButton = GGButton(defaultButtonImage: "sound_mute", activeButtonImage: "sound_mute", buttonAction: didTapOnSound)
                soundButton!.xScale = 0.05
                soundButton!.yScale = 0.05
                soundButton!.position = CGPoint(x: 100, y: 50)
                addChild(soundButton!)
            }
        }else{
            soundButton = GGButton(defaultButtonImage: "sound_mute", activeButtonImage: "sound_mute", buttonAction: didTapOnSound)
            soundButton!.xScale = 0.05
            soundButton!.yScale = 0.05
            soundButton!.position = CGPoint(x: 100, y: 50)
            soundOn = false
            addChild(soundButton!)
        }
    }
    

    func startGameButtonDown(){
        let startGameAction = SKAction.runBlock{
            let reval = SKTransition.flipHorizontalWithDuration(0.5)
            self.view?.presentScene( GamePlayScene(size: self.size), transition: reval)
        }
        self.runAction(startGameAction)
    }
    
    func twitter(){
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.baidu.com")!)
    }
    
    func didTapOnSound(){
        if soundOn! {
            soundButton!.defaultButton.texture = SKTexture(imageNamed: "sound_mute")
            soundButton!.activeButton.texture = SKTexture(imageNamed: "sound_mute")
            soundOn = false
        }else{
            soundButton!.defaultButton.texture = SKTexture(imageNamed: "sound_on")
            soundButton!.activeButton.texture = SKTexture(imageNamed: "sound_on")
            soundOn = true
        }
        self.myDelegate?.didChangeSound()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
