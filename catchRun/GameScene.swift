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
    func autoMatch()
}

let multiplayerButtonPressed: String! = "multiplayer button pressed"
class GameScene: SKScene, GADInterstitialDelegate, MultiplayerProtocol {
    var myDelegate:sceneDelegate?
    var soundButton:GGButton?
    var soundOn:Bool?


    // this is used to transfer moving data
    var networkEngine: Multiplayer!
    var vc: GameViewController!
    
    //------network layer var
    var currentIndex: Int! // which player
    var players: Array<PlayerNode>!
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let background:SKSpriteNode = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        background.size = CGSize(width: self.size.width, height: self.size.height)
        addChild(background)
        
        let startSinglePlayerGameButton: GGButton = GGButton(defaultButtonImage: "button1", activeButtonImage: "button2", buttonAction: startGameButtonDown)
        startSinglePlayerGameButton.xScale = 0.3
        startSinglePlayerGameButton.yScale = 0.3
        startSinglePlayerGameButton.position = CGPoint(x: size.width * 0.5, y: size.height * 0.45 )
        addChild(startSinglePlayerGameButton)
        
        let startMultiPlayerGameButton: GGButton = GGButton(defaultButtonImage: "button1", activeButtonImage: "button2", buttonAction: startMultiPlayerGameButtonDown)
        startMultiPlayerGameButton.xScale = 0.3
        startMultiPlayerGameButton.yScale = 0.3
        startMultiPlayerGameButton.position = CGPoint(x: size.width * 0.5, y: size.height * 0.55 )
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
            self.view?.presentScene( GamePlayScene(size: self.size), transition: reval)
        }
        //gameStarted = True
        self.runAction(startGameAction)
    }

    
    func startMultiPlayerGameButtonDown(){
        
        NSNotificationCenter.defaultCenter().postNotificationName(multiplayerButtonPressed, object: nil)
        //TODO implement the networking button here!
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "navigateToGameScene", name: gameBegin, object: nil)

        print("auto- match start")
       // NSNotificationCenter.defaultCenter().addObserver(self.vc, selector: "playerAuthenticated", name: LocalPlayerIsAuthenticated, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAuthenticaionViewController", name: presentAuthentication, object: nil)
//        GameCenterConnector.sharedInstance().authenticatePlayer()
    }
    
    func navigateToGameScene(){
        let startGameAction = SKAction.runBlock{
            let reval = SKTransition.flipHorizontalWithDuration(0.5)
            self.view?.presentScene( GamePlayScene(size: self.size), transition: reval)
        }
        //gameStarted = True
        self.runAction(startGameAction)
    }
    
//    func showAuthenticaionViewController(){
//        self.vc.presentViewController(GameCenterConnector.sharedInstance().authenticationViewController!, animated: true, completion: nil)
//    }
    
    
//    func playerAuthenticated(){
//        //var skview: SKView! = self.vc.view as SKView
//       // var scene: GameScene! = skview.scene as GameScene
////        self.vc.networkEngine = Multiplayer()
//        networkEngine.delegate = self
//        self.networkEngine = Multiplayer()
//        GameCenterConnector.sharedInstance().findMatchWithMinPlayer(2, maxPlayers: 2, viewControllers: vc, delegate: self.vc.networkEngine)
//    }
    
    
    
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
    
    //conform multiplayer protocol
    func matchEnded(){
        
    }
    
    // set current player index, such as P1
    func setCurrentPlayerIndex(index: Int){
        currentIndex = index
    }
    
    
    // move p1 or p2, to which direction
    func movePlayerAtIndex(index: String, position: CGPoint){
//        var player: PlayerNode! = players[index] as PlayerNode
//        player.moving(direction)
    }
    
    // we can check game over by only one side
    // for example: P1 wins, we only check P1. then send game over info to P2
    func gameOver(leftWon: Bool){
        
    }
    func setPlayerAlias(playerAliases: NSArray){
        
    }
    
    
    
    
}
