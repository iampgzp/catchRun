//
//  GameCenterConnector.swift
//  catchRun
//
//  Created by Li, Xiaoping on 12/19/14.
//  Copyright (c) 2014 LUSS. All rights reserved.
//

import Foundation
import GameKit
import SpriteKit


protocol GameConnectorDelegate{
    func matchStarted()
    func matchEnded()
    func match(match: GKMatch, didReceiveData data:NSData, fromPlayer playerID: NSString)
}
let presentAuthentication: String! = "present authentication view controller"
var instance: GameCenterConnector?
class GameCenterConnector: NSObject,GKMatchmakerViewControllerDelegate, GKMatchDelegate{

    var delegate : GameConnectorDelegate!
    var playerDict: NSMutableDictionary!
    var gameCenterEnabled: Bool!
    var leaderboardIdentifier : String!
    var match:GKMatch!
    var matchStarted: Bool! = false
    var authenticationViewController: UIViewController?
    var vc: UIViewController?
   // let presentAuthentication: String! = "present authentication view controller"
    // use to keep track of last error
    var lastError : NSError?
    init(viewc : UIViewController){
        super.init()
        gameCenterEnabled = true
        self.vc = viewc
       // authenticatePlayer()
    }
    
    // create a singleton pattern here to keep all game center code into one spot
    class func sharedInstance(viewc : UIViewController) -> GameCenterConnector{
        var onceToken: dispatch_once_t?
        if instance == nil{
            instance = GameCenterConnector(viewc: viewc)
        }
//        var sharedGameConnector:GameCenterConnector?
//        var onceToken: dispatch_once_t?
//        dispatch_once(&onceToken, {sharedGameConnector = GameCenterConnector()} )
        return instance!
    }
    
    
    // authenticate user in the gamecenter
    // we can call it in viewDidLoad
    // Authentication is usually in background, so we need a handler while user is 
    // navigating in the game scene
    func authenticatePlayer(){
        var localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        //if player is not logged into game center, game kit framework will pass a view controller to authenticate.
        localPlayer.authenticateHandler = {(viewController: UIViewController!, error:NSError!) ->Void in
            if viewController != nil{
                //self.presentViewController(viewController, animated:false, completion: nil)
                self.vc?.presentViewController(viewController, animated: true, completion: nil)
              //  self.setAuthenticationViewController(viewController)
            }else{
                // authenticated is a property for GKLocalPlayer, if it is false, it means user currenly is not successfully log into game center
                if localPlayer.authenticated{
                    self.gameCenterEnabled = true
                    localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({(leaderboardIdentifier: String!, error: NSError!) -> Void in
                        if error != nil{
                            println(error.localizedDescription)
                        }
                        else{
                             self.leaderboardIdentifier = leaderboardIdentifier
                        }
                    })
                }else{
                    // due to some reason: user cancel log in or log in not success, we need to disable all game center feature
                    self.gameCenterEnabled = false
                }
            }
        }
    }
    
    // store viewcontroller and send notification
    func setAuthenticationViewController(viewController: UIViewController?){
        if (viewController != nil){
            self.authenticationViewController = viewController
            NSNotificationCenter.defaultCenter().postNotificationName(presentAuthentication, object: self)
        }
    }
    
    func setLastError(error: NSError?){
        self.lastError = error?.copy() as? NSError
        if ((self.lastError) != nil){
            println(self.lastError?.userInfo?.description)
        }
    }
    
    func findMatchWithMinPlayer(minPlayer: Int, maxPlayers maxPlayer:Int, viewControllers viewController: UIViewController, delegate: GameConnectorDelegate){
        //if gamecenter is not enabled, do nothing
//        if !self.gameCenterEnabled{
//            return;
//        }
        self.matchStarted = false
        self.match = nil
        viewController.dismissViewControllerAnimated(false, completion: nil)
        //GKMatchRequest is the built-in api to set min amount and max amount of players.
        var request:GKMatchRequest! = GKMatchRequest()
        request.minPlayers = minPlayer
        request.maxPlayers = maxPlayer
        var matchViewController:GKMatchmakerViewController! = GKMatchmakerViewController(matchRequest: request)
        matchViewController.matchmakerDelegate = self
        //present the game pairing view
        viewController.presentViewController(matchViewController, animated: true, completion: nil)
    }
    
    // when user cancel the game pairing
    func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController!){
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    // when there is error for game pairing
    func matchmakerViewController(viewController: GKMatchmakerViewController!, didFailWithError error: NSError!){
        viewController.dismissViewControllerAnimated(true, completion: nil)
        NSLog("Erro matching: %", error.localizedDescription)
    }
    // when game pairing is ok, and game is ready to go
    func matchmakerViewController(viewController: GKMatchmakerViewController, didFindMatch match: GKMatch){
        viewController.dismissViewControllerAnimated(true, completion: nil)
        self.match = match
        match.delegate = self
        //match object keeps track amount of players need to finish connecting, if it is 0, all set
        if !self.matchStarted && match.expectedPlayerCount == 0{
            NSLog("Ready to start game")
            lookUpPlayer()
        }
    }
    // when another player sends data to you, this method will be called.
    func match(match: GKMatch!, didReceiveData data: NSData!, fromPlayer playerID: String!) {
        if self.match != match{
            return;
        }
        self.delegate?.match(match, didReceiveData: data, fromPlayer: playerID)
    }
    // implement GKmatchDelegate
    func match(match: GKMatch, didReceiveData data: NSData, fromPlayer playerID: NSString, didChangeState state: GKPlayerConnectionState){
        if self.match != match{
            return
        }
        switch state {
        case GKPlayerConnectionState.StateConnected:
            NSLog("player connected")
            if !self.matchStarted && match.expectedPlayerCount == 0{
                NSLog("ready to start")
                lookUpPlayer()
            }
            break
        case GKPlayerConnectionState.StateDisconnected:
            NSLog("Player disconnected")
            self.matchStarted = false
            self.delegate?.matchEnded()
            break
        default:
            println("connection state need to be inputted")
        }
    }
    // implement GKmatchDelegate
    func match(match: GKMatch!, didFailWithError error: NSError!) {
        if self.match != match{
            return;
        }
        NSLog("match failed with error %", error.localizedDescription)
        matchStarted = false
        self.delegate?.matchEnded()
    }
    //lookup players
    func lookUpPlayer(){
        NSLog("Looking up player", self.match.playerIDs.count)
        GKPlayer.loadPlayersForIdentifiers(match.playerIDs, withCompletionHandler: {(players: [AnyObject]!, error: NSError?) -> Void in
            if error != nil{
                NSLog("Error to load player's information", error!.localizedDescription);
                self.matchStarted = false
                // delegate.matchEned
            } else{
                self.playerDict = NSMutableDictionary(capacity: players.count)
                for player in players {
                    NSLog("Found Player : %", player.alias)
                    self.playerDict?.setObject(player, forKey: player.playerID)
                }
                self.playerDict?.setObject(GKLocalPlayer.localPlayer(), forKey: GKLocalPlayer.localPlayer().playerID)
                self.matchStarted = true
                self.delegate.matchStarted()
                
            }
        })
    }
}


