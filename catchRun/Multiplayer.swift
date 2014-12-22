//
//  Multiplayer.swift
//  catchRun
//
//  Created by Li, Xiaoping on 12/21/14.
//  Copyright (c) 2014 LUSS. All rights reserved.
//

import Foundation
import GameKit


class Multiplayer{
    
    func sendData(data: NSData){
        var error:NSError?;
        var gameConnector: GameCenterConnector = GameCenterConnector.sharedInstance()
        var success: Bool! = gameConnector.match.sendDataToAllPlayers(data, withDataMode: GKMatchSendDataMode.Reliable, error: &error)
        if (!success){
            println(error?.localizedDescription)
            matchEnded()
        }
    }
    
    // send move infomation to game center
    func sendMove(){
        var data: NSData!
        sendData(data)
    }
    
    func matchEnded(){
        println("Match ended")
        //delegate.matchEnded()
    }
}