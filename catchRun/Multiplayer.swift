//
//  Multiplayer.swift
//  catchRun
//
//  Created by Li, Xiaoping on 12/21/14.
//  Copyright (c) 2014 LUSS. All rights reserved.
//

import Foundation
import GameKit

enum GameState: Int{
    case waitingForMatch = 0
    case waitingForRandomPairing
    case waitingForStart
    case gameActive
    case gameStateDone
}

class Multiplayer: NSObject, GameConnectorDelegate{
    
    var receiveAllRandomPairingNumber: Bool!
    var isP1: Bool!
    var gameState: GameState!
    var randomNumber: UInt32!
    var orderOfPlayers: Dictionary<String, UInt32>!

    let playerIdKey = "playerID"
    var viewc: UIViewController!
    let randomNumberKey = "randomNumber"
    
    init(viewc: UIViewController){
        super.init()
        self.viewc = viewc
        randomNumber = arc4random()
        gameState = GameState.waitingForMatch
        orderOfPlayers = Dictionary<String, UInt32>()
        orderOfPlayers.updateValue(randomNumber, forKey: GKLocalPlayer.localPlayer().playerID)
//        orderOfPlayers.addObject((playerIdKey: GKLocalPlayer.localPlayer().playerID, randomNumberKey: randomNumber.description))
        
    }
    
    func sendData(data: NSData){
        var error:NSError?;
        var gameConnector: GameCenterConnector = GameCenterConnector.sharedInstance(viewc)
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
    
    func matchStarted() {
        NSLog("match start successfully")
        if receiveAllRandomPairingNumber == true{
            gameState = GameState.waitingForStart
        }else{
            gameState = GameState.waitingForRandomPairing
        }
        sendRandomPairingNumber()
        startGame()
    }
    
    func sendRandomPairingNumber(){
        var data = NSData(bytes: &randomNumber, length: 32)
        sendData(data)
    }
    
    func sendMatchBegin(){
        var message = "match begin"
        var data = NSData(bytes: &message, length: 32)
        sendData(data)
    }
    
    func startGame(){
        if isP1 == true && gameState == GameState.waitingForStart{
           gameState = GameState.gameActive
            self.sendMatchBegin()
        }
    }
    
    func match(match: GKMatch, didReceiveData data: NSData, fromPlayer playerID: NSString) {
        
    }
    
    func matchEnded(){
        println("Match ended")
        //delegate.matchEnded()
    }

}