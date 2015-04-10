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
let LocalPlayerIsAuthenticated = "local_player_authenticated"

// singleton object
var instance: GameCenterConnector?

class GameCenterConnector: NSObject,GKMatchmakerViewControllerDelegate, GKMatchDelegate{
    var delegate : GameConnectorDelegate!
    //use to for easily look up player
    var playerDict: NSMutableDictionary!
    var gameCenterEnabled  = false

    
    var match:GKMatch!
    var matchStarted: Bool! = false
    var authenticationViewController: UIViewController?

    
    var lastError : NSError?
    var playerIds : Array<String>? = Array<String>()
    
    
    // create a singleton pattern here to keep all game center code into one spot
    class func sharedInstance() -> GameCenterConnector{
        if instance == nil{
            instance = GameCenterConnector()
        }
        return instance!
    }
    
    // authenticate user in the gamecenter
    // we can call it in viewDidLoad
    // Authentication is usually in background, so we need a handler while user is
    // navigating in the game scene
    func authenticatePlayer(){
        print("start authenticate player \n")
        var localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        if localPlayer.authenticated{
            gameCenterEnabled = true
            print("user is already authenticated")
            NSNotificationCenter.defaultCenter().postNotificationName(LocalPlayerIsAuthenticated, object: nil)
        }
        
        //if player is not logged into game center, game kit framework will pass a view controller to authenticate.
        localPlayer.authenticateHandler = {(viewController: UIViewController!, error:NSError!) ->Void in
            self.setLastError(error)
            if viewController != nil{
                self.setAuthenticationViewController(viewController)
                println("prepare to show log in page \n")
            }else{
                // authenticated is a property for GKLocalPlayer, if it is false, it means user currenly is not successfully log into game center
                if localPlayer.authenticated {
                    println("local player is authenticaed \n")
                    self.gameCenterEnabled = true
                    NSNotificationCenter.defaultCenter().postNotificationName(LocalPlayerIsAuthenticated, object: nil)
                }else{
                    println("it is failed log in \n")
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
    
    
    /*search player for game matching*/
    func findMatchWithMinPlayer(minPlayer: Int, maxPlayers maxPlayer:Int, viewControllers viewController: UIViewController, delegate: GameConnectorDelegate){
        //if gamecenter is not enabled, do nothing
        if !self.gameCenterEnabled{
            return;
        }

        self.delegate = delegate
        self.matchStarted = false
        self.match = nil
        viewController.dismissViewControllerAnimated(false, completion: nil)
        //GKMatchRequest is the built-in api to set min amount and max amount of players.
        var request:GKMatchRequest! = GKMatchRequest()
        request.minPlayers = minPlayer
        request.maxPlayers = maxPlayer
        print("set up GKMatchRequest")
        var matchViewController:GKMatchmakerViewController! = GKMatchmakerViewController(matchRequest: request)
        matchViewController.matchmakerDelegate = self
        //present the game pairing view
        NSLog("Present auto-match view for players \n")
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
    
    // CALLED WHEN PEER TO PEER IS FOUND
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
    
    // IMPLEMENT GKMATCHDELEGATE
    // DECODE INCOMING DATA
    // when another player sends data to you, this method will be called.
    func match(match: GKMatch!, didReceiveData data: NSData!, fromPlayer playerID: String!) {
        if self.match != match{
            return;
        }
        NSLog("decoding incoming data")
        self.delegate?.match(match, didReceiveData: data, fromPlayer: playerID)
    }
    
    // CALLED WHEN STATE CHANGES
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
    
    //CALLED AFTER PEER TO PEER IS FOUND
    //call lookupPlayer() when match is ready. store playerid and player object into dictionary
    func lookUpPlayer(){
        NSLog("Looking up remote player %d", self.match.playerIDs.count)
        
        // withCompletionHandler returns GKPlayer object for each player in the match.
        GKPlayer.loadPlayersForIdentifiers(match.playerIDs, withCompletionHandler: {(players: [AnyObject]!, error: NSError?) -> Void in
            if error != nil{
                NSLog("Error to load player's information %s", error!.localizedDescription);
                self.matchStarted = false
                // delegate.matchEned
            } else{
                self.playerDict = NSMutableDictionary(capacity: players.count)
                for player in players {
                    NSLog("Found Player alias \(player.alias) \n")
                    // PLAYERDICT CONTAINS ID --> PLAYER OBJECT
                    self.playerDict?.setObject(player, forKey: player.playerID)
                    self.playerIds?.append(player.playerID)
                }
                self.playerDict!.setObject(GKLocalPlayer.localPlayer(), forKey: GKLocalPlayer.localPlayer().playerID)
                self.matchStarted = true
                self.delegate.matchStarted()
                
            }
        })
    }
    
    func getRemoteCount() -> Int{
        NSLog("get remote count for remote players")
        return self.match.playerIDs.count
    }
    
    func getPlayerIds() -> Array<String>{
        return self.playerIds!
    }
    
    func getLocalPlayerID() -> String{
        return GKLocalPlayer.localPlayer().playerID
    }
 
}


