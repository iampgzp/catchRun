//
//  GameScene.swift
//  catchRun
//
//  Created by Shihao Ji on 12/16/14.
//  Copyright (c) 2014 LUSS. All rights reserved.
//

import SpriteKit
import Social

protocol GameSceneDelegate{
    func didChangeSound()
    func findPlayer()
    func showAuthenticaionViewController()
}

class GameScene: SKScene {
    var myDelegate:GameSceneDelegate?
    var soundButton:GGButton?
    var soundOn:Bool?
    
    // this is used to transfer moving data
    //var networkEngine: Multiplayer!
    var vc: GameViewController!
    
    //------network layer var
    var currentIndex: Int! // which player
    var players: Array<PlayerNode>!
    
    override func didMoveToView(view: SKView) {
        NSLog("Game Scene is moved to view")
        /* Setup your scene here */
        let background:SKSpriteNode = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        background.size = CGSize(width: self.size.width, height: self.size.height)
        addChild(background)
        
        let startSinglePlayerGameButton: GGButton = GGButton(defaultButtonImage: "singlePlayerButton", activeButtonImage: "singlePlayerButton", buttonAction: startGameButtonDown)
        startSinglePlayerGameButton.xScale = 0.6
        startSinglePlayerGameButton.yScale = 0.6
        startSinglePlayerGameButton.position = CGPoint(x: size.width * 0.5, y: size.height * 0.53 )
        addChild(startSinglePlayerGameButton)
        
        let startMultiPlayerGameButton: GGButton = GGButton(defaultButtonImage: "multiPlayerButton", activeButtonImage: "multiPlayerButton", buttonAction: startMultiPlayerGameButtonDown)
        startMultiPlayerGameButton.xScale = 0.6
        startMultiPlayerGameButton.yScale = 0.6
        startMultiPlayerGameButton.position = CGPoint(x: size.width * 0.5, y: size.height * 0.37 )
        addChild(startMultiPlayerGameButton)
        
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
            let gamePlayScene = GamePlayScene(size: self.size)
            gamePlayScene.isSinglePlayer = true
            gamePlayScene.myDelegate = self.myDelegate
            self.view?.presentScene( gamePlayScene, transition: reval)
        }
        self.runAction(startGameAction)
    }

    
    func startMultiPlayerGameButtonDown(){
        myDelegate!.findPlayer()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "navigateToGameScene", name: gameBegin, object: nil)
    }
    
    //NAVIGATE TO PLAY SCENE
    func navigateToGameScene(){
        var gameplayscene = GamePlayScene(size: self.size)
        var multiplayer: Multiplayer! = GameCenterConnector.sharedInstance().delegate as Multiplayer
        multiplayer.delegate = gameplayscene
        var randomDict: Dictionary<String, Double> = multiplayer.getRandomNumber()
        var ghostkey:String!
        var maxvalue = randomDict[GameCenterConnector.sharedInstance().getLocalPlayerID()]
        // find minimum key, set it as ghost key
        for key in randomDict.keys{
            var keyrand = randomDict[key] as Double!
            if maxvalue >= (keyrand){
                ghostkey = key
                maxvalue = keyrand
            }
        }
        gameplayscene.setGhostKey(ghostkey)
        NSLog("The ghost playerID is \(ghostkey)")
        gameplayscene.networkEngine = multiplayer
        gameplayscene.isSinglePlayer = false
        gameplayscene.myDelegate = self.myDelegate
        let startGameAction = SKAction.runBlock{
            let reval = SKTransition.flipHorizontalWithDuration(0.5)
            self.view?.presentScene(gameplayscene, transition: reval)
        }
        //gameStarted = True
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

}
