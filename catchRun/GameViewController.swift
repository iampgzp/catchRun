//
//  GameViewController.swift
//  catchRun
//
//  Created by Ji Pei on 12/16/14.
//  Copyright (c) 2014 LUSS. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, GADBannerViewDelegate, GADInterstitialDelegate, AVAudioPlayerDelegate, sceneDelegate, GameConnectorDelegate{

    
    var networkEngine: Multiplayer!
    var fullAd:GADInterstitial?
    var audioControl : AudioController?
   
    var gameCenterConenctor: GameCenterConnector!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // banner ad view init
        var banner = GADBannerView(adSize: kGADAdSizeSmartBannerLandscape)
        banner.adUnitID = "ca-app-pub-6314301496407347/1491324510"
        banner.delegate = self
        banner.rootViewController = self
        var request2:GADRequest = GADRequest()
        self.view.addSubview(banner)
        request2.testDevices = [ GAD_SIMULATOR_ID ]
        banner.loadRequest(request2)
    
        //interstitial ad view init
        fullAd = GADInterstitial()
        fullAd!.adUnitID = "ca-app-pub-6314301496407347/6061124916"
        fullAd!.delegate = self
        fullAd!.loadRequest(request2)

        // bgm 
        audioControl = AudioController()
        audioControl!.tryPlayMusic()
        
        
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            scene.myDelegate = self
            scene.soundOn = true
            skView.presentScene(scene)
        }

    //    self.gameCenter = GameCenter(rootViewController: self)
        GameCenterConnector.sharedInstance(self).authenticatePlayer()
        GameCenterConnector.sharedInstance(self).findMatchWithMinPlayer(2, maxPlayers: 2, viewControllers: self, delegate: self)
       // self.authenticateLocalPlayer()
    }
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
        if GameCenterConnector.sharedInstance(self).gameCenterEnabled == true {
            GameCenterConnector.sharedInstance(self).findMatchWithMinPlayer(2, maxPlayers: 2, viewControllers: self, delegate: self)
        }
        
    }
    
    func playerAuthenticated(){
        var skview: SKView! = self.view as SKView
        var scene: GamePlayScene! = skview.scene as GamePlayScene
        self.networkEngine = Multiplayer(viewc: self)
        networkEngine.delegate = scene
        
        
    }

    
//    func authenticateLocalPlayer() {
//        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
//        //if player is not logged into game center, game kit framework will pass a view controller to authenticate.
//        localPlayer.authenticateHandler = {(viewController, error) ->Void in
//            if viewController != nil{
//                self.presentViewController(viewController, animated:true, completion: nil)
//                print("not nil")
//            }else{
//                // authenticated is a property for GKLocalPlayer, if it is false, it means user currenly is not successfully log into game center
//               // print("yes, it is nil")
//                if localPlayer.authenticated{
//                   // self.gameCenterEnabled = true
//                    print("yes, it is alreaady authenticated")
//                    localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({(leaderboardIdentifier: String!, error: NSError!) -> Void in
//                        if error != nil{
//                            println(error.localizedDescription)
//                        }
//                        else{
//                            //self.leaderboardIdentifier = leaderboardIdentifier
//                            
//                        }
//                    })
//                }else{
//                    print("it is not authenticated yet")
//                    //self.presentViewController(viewController, animated:true, completion: nil)
//                    //self.gameCenterEnabled = false
//                }
//            }
//        }
//    }
    
//    func showAuthenticationViewController() {
//        //present this viewController
//        self.presentViewController(GameCenterConnector.sharedInstance().authenticationViewController!, animated: true, completion: nil)
//        //GameCenterConnector.sharedInstance().authenticationViewController
//    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: GADIntersititialDelegate
    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        fullAd!.presentFromRootViewController(self)
    }
    
    func didChangeSound() {
        if audioControl!.backgroundMusicPlaying{
            audioControl!.stopMusic()
        }else{
            audioControl!.tryPlayMusic()
        }
    }
    
    func match(match: GKMatch, didReceiveData data: NSData, fromPlayer playerID: NSString) {
        print("receive data")
    }
    
    func matchEnded() {
        print("match ended")
    }
    func matchStarted() {
        print("match started")
    }
}
