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

    
    var gameCenterEnabled: Bool!
    var leaderboardIdentifier : String!
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
    func authenticatePlayer(){
        var localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController: UIViewController!, error:NSError!) ->Void in
            if viewController != nil{
                //self.presentViewController(viewController, animated:true, completion: nil)
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

}