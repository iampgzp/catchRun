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

class GameViewController: UIViewController, GADBannerViewDelegate, GADInterstitialDelegate, GameSceneDelegate{
    var networkEngine : Multiplayer?
    var fullAd = GADInterstitial()
    var audioControl = AudioController()
    
    //MARK : UIViewController Methods
    override func viewDidLoad() {
        NSLog("Game View Controller view did load")
        super.viewDidLoad()
        
        // add banner ad and full screen ad
        var banner = GADBannerView(adSize: kGADAdSizeSmartBannerLandscape)
        banner.adUnitID = "ca-app-pub-6314301496407347/1491324510"
        banner.delegate = self
        banner.rootViewController = self
        self.view.addSubview(banner)
        fullAd.adUnitID = "ca-app-pub-6314301496407347/6061124916"
        fullAd.delegate = self
        
        var request:GADRequest = GADRequest()
        request.testDevices = [GAD_SIMULATOR_ID]
        banner.loadRequest(request)
        fullAd.loadRequest(request)
        
        // add notification for authentication
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAuthenticaionViewController", name: presentAuthentication, object: nil)
        
        // try authenticate player will invoke presentAuthentication if not already authenticated
        GameCenterConnector.sharedInstance().authenticatePlayer()
        
        // load the game scene
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            // my delegate is used for getting the event for gameScene sound button
            scene.myDelegate = self
            scene.soundOn = true
            
            skView.presentScene(scene)
        }
        
        // try play music
        audioControl.tryPlayMusic()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        // only allow two orientations
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
    
    //MARK: GADIntersititialDelegate
    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        // got the full screen ad, let's display it
        fullAd.presentFromRootViewController(self)
        NSLog("Full Screen Ad is on")
    }
    
    //MARK: Scene Delegate
    func didChangeSound() {
        if audioControl.backgroundMusicPlaying{
            audioControl.stopMusic()
            NSLog("stop playing music")
        }else{
            audioControl.tryPlayMusic()
            NSLog("start playing music")
        }
    }
    
    func showAuthenticaionViewController(){
        NSLog("Present Game Center View")
        self.presentViewController(GameCenterConnector.sharedInstance().authenticationViewController!, animated: true, completion: nil)
    }
    
    func findPlayer(){
        NSLog("Try find player")
        if GameCenterConnector.sharedInstance().gameCenterEnabled {
            NSLog("Game Center is enabled")
            if  self.networkEngine == nil{
                self.networkEngine = Multiplayer()
            }
            GameCenterConnector.sharedInstance().findMatchWithMinPlayer(2, maxPlayers: 2, viewControllers: self, delegate: self.networkEngine!)
        }else{
            NSLog("Game Center is disabled")
        }
    }
}
