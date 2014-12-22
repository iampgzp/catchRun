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

var instance: GameCenterConnector?
class GameCenterConnector: NSObject,GKMatchmakerViewControllerDelegate, GKMatchDelegate{

    var delegate : GameConnectorDelegate?
    var playerDict: NSMutableDictionary!
    var gameCenterEnabled: Bool!
    var leaderboardIdentifier : String!
    var match:GKMatch!
    var matchStarted: Bool! = false
    var authenticationViewController: UIViewController?
    let presentAuthentication: String! = "present authentication view controller"
    // use to keep track of last error
    var lastError : NSError?
    override init(){
        super.init()
        gameCenterEnabled = true
    }
    
    // create a singleton pattern here to keep all game center code into one spot
    class func sharedInstance() -> GameCenterConnector{
        var onceToken: dispatch_once_t?
        if instance == nil{
            instance = GameCenterConnector()
            
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
        localPlayer.authenticateHandler = {(viewController: UIViewController!, error:NSError!) ->Void in
            if viewController != nil{
                self.setAuthenticationViewController(viewController)
            }else{
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
        if !self.gameCenterEnabled{
            return;
        }
        self.matchStarted = false
        self.match = nil
        viewController.dismissViewControllerAnimated(false, completion: nil)
        var request:GKMatchRequest! = GKMatchRequest()
        request.minPlayers = minPlayer
        request.maxPlayers = maxPlayer
        var matchViewController:GKMatchmakerViewController! = GKMatchmakerViewController(matchRequest: request)
        //matchViewController?.matchRequest(request)
        matchViewController.matchmakerDelegate = self
        viewController.presentViewController(matchViewController, animated: true, completion: nil)
    }
    
    // implement GKmatchmakerViewControllerDelegate
    func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController!){
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    // implement GKmatchmakerViewControllerDelegate
    func matchmakerViewController(viewController: GKMatchmakerViewController!, didFailWithError error: NSError!){
        viewController.dismissViewControllerAnimated(true, completion: nil)
        NSLog("Erro matching: %", error.localizedDescription)
    }
    // implement GKmatchmakerViewControllerDelegate
    func matchmakerViewController(viewController: GKMatchmakerViewController, didFindMatch match: GKMatch){
        viewController.dismissViewControllerAnimated(true, completion: nil)
        self.match = match
        match.delegate = self
        if !self.matchStarted && match.expectedPlayerCount == 0{
            NSLog("Ready to start game")
        }
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
        self.matchStarted = false
        self.delegate?.matchEnded()
    }
}
    //func match
    
    //lookup players
//    func lookUpPlayer(){
//        NSLog("Looking up player", self.match.playerIDs.count)
//        GKPlayer.loadPlayersForIdentifiers(self.match.playerIDs, withCompletionHandler: {(players: [AnyObject]!, error: NSError?) -> Void in
//            if error != nil{
//                NSLog("Error to load player's information", error!.localizedDescription);
//                self.matchStarted = false
//                // delegate.matchEned
//            } else{
//                for player in players {
//                    NSLog("Found Player : %", player.alias)
//                }
//            }
//        })
//        
//    }

