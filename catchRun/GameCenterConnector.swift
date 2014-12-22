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

var instance: GameCenterConnector?
class GameCenterConnector: NSObject{

    var playerDict: NSMutableDictionary!
    var gameCenterEnabled: Bool!
    var leaderboardIdentifier : String!
    var match:GKMatch!
    var matchStarted: Bool! = false
    override init(){
        super.init()
        gameCenterEnabled = false
    }
    
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
    
    func setAuthenticationViewController(viewController: UIViewController){
        
    }
    
    //lookup players
    func lookUpPlayer(){
        NSLog("Looking up player", match.playerIDs.count)
        GKPlayer.loadPlayersForIdentifiers(match.playerIDs, withCompletionHandler: {(players: [AnyObject]!, error: NSError?) -> Void in
            if error != nil{
                NSLog("Error to load player's information", error!.localizedDescription);
                self.matchStarted = false
                // delegate.matchEned
            } else{
                for player in players {
                    NSLog("Found Player : %", player.alias)
                }
            }
        })
        
    }
}