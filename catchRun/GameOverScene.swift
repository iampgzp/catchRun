//
//  GameOverScene.swift
//  catchRun
//
//  Created by seehao on 14/12/22.
//  Copyright (c) 2014年 LUSS. All rights reserved.
//

import Foundation
import SpriteKit
import Social

class GameOverScene: SKScene, GADInterstitialDelegate {
    override func didMoveToView(view: SKView) {
        let gameOverLabel: SKLabelNode = SKLabelNode(text: "You Won")
        gameOverLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        gameOverLabel.xScale = 1.0
        gameOverLabel.yScale = 1.0
        addChild(gameOverLabel)
        
        let startGameButton: GGButton = GGButton(defaultButtonImage: "button1", activeButtonImage: "button2", buttonAction: startGameButtonDown)
        startGameButton.xScale = 0.3
        startGameButton.yScale = 0.3
        startGameButton.position = CGPoint(x: size.width * 0.5, y: size.height * 0.8 )
        addChild(startGameButton)
        
        let twitterButton:GGButton = GGButton(defaultButtonImage: "twitter", activeButtonImage: "twitter", buttonAction: shareToWeibo)
        twitterButton.xScale = 0.3
        twitterButton.yScale = 0.3
        twitterButton.position = CGPoint(x: 100, y: 100)
        addChild(twitterButton)
    }
    
    func startGameButtonDown(){
        let startGameAction = SKAction.runBlock{
            let reval = SKTransition.flipHorizontalWithDuration(0.5)
            self.view?.presentScene( GameScene(size: self.size), transition: reval)
        }
        self.runAction(startGameAction)
    }
    
    func shareToWeibo(){
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeSinaWeibo){
            let weiboContent = SLComposeViewController(forServiceType: SLServiceTypeSinaWeibo)
            weiboContent.setInitialText("Test")
            self.view?.window?.rootViewController?.presentViewController(weiboContent, animated: true, completion: nil)
        }
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}