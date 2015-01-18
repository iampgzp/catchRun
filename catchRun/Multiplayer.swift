//
//  Multiplayer.swift
//  catchRun
//
//  Created by Li, Xiaoping on 12/21/14.
//  Copyright (c) 2014 LUSS. All rights reserved.
//

import Foundation
import GameKit

protocol MultiplayerProtocol{
    func matchEnded()
    func setCurrentPlayerIndex(index: Int)
    func movePlayerAtIndex(index: Int)
    func gameOver(leftWon: Bool)
    func setPlayerAlias(playerAliases: NSArray)
}

enum GameState: Int{
    case waitingForMatch = 0
    case waitingForRandomPairing
    case waitingForStart
    case gameActive
    case gameStateDone
}

enum MessageType: Int{
    case messageTypeRandomNumber = 0
    case messageTypeGameBegin
    case messageTypeMove
    case messageTypeGameOver
}

struct Message{
    var messageType: MessageType
}

struct MessageRandomNumber{
    var message: Message
    var randomNumber: Int
}

struct MessageGameBegin{
    var message: Message
}

struct MessageMove{
    var message: Message
}

struct MessageGameOver{
    var message: Message
    var leftWon: Bool
}

class Multiplayer: NSObject, GameConnectorDelegate{
    
    var receiveAllRandomPairingNumber: Bool!
    var isP1: Bool!
    var gameState: GameState!
    var randomNumber: Int!
    var orderOfPlayers: NSMutableArray!
    //var orderOfPlayers: Dictionary<String, UInt32>!
    var delegate: MultiplayerProtocol!
    let playerIdKey: String = "playerID"
    var viewc: UIViewController!
    let randomNumberKey: String = "randomNumber"
    
    init(viewc: UIViewController){
        super.init()
        self.viewc = viewc
        randomNumber = Int(arc4random())
        gameState = GameState.waitingForMatch
        orderOfPlayers = NSMutableArray()
        //var dic: NSMutableDictionary! = new NSMutableDictionary()
        var dic = [playerIdKey as String: GKLocalPlayer.localPlayer().playerID as String, randomNumberKey: randomNumber]
        orderOfPlayers.addObject(dic)
//        orderOfPlayers = Dictionary<String, UInt32>()
//        orderOfPlayers.updateValue(randomNumber, forKey: GKLocalPlayer.localPlayer().playerID)
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
    

    
    func sendRandomPairingNumber(){
        var message: MessageRandomNumber!
        message.message.messageType = MessageType.messageTypeRandomNumber
        message.randomNumber = self.randomNumber
        var data = NSData(bytes: &message, length: sizeof(MessageRandomNumber))
        sendData(data)
    }
    
    func sendGameBegin(){
        var message: MessageGameBegin!
        message.message.messageType = MessageType.messageTypeGameBegin
        var data = NSData(bytes: &message, length: sizeof(MessageGameBegin))
        sendData(data)
    }
    
    func sendGameEnd(leftWon: Bool){
        var message : MessageGameOver!
        message.message.messageType = MessageType.messageTypeGameOver
        message.leftWon = leftWon
        var data = NSData(bytes: &message, length: sizeof(MessageGameOver))
        sendData(data)
    }
    
    func tryStartGame(){
        if isP1 == true && gameState == GameState.waitingForStart{
           gameState = GameState.gameActive
            self.sendGameBegin()
            
            self.delegate.setCurrentPlayerIndex(0)
            self.processPlayerAliases()
        }
    }
    
    func allRandomInfoReceived() -> Bool{
        var receiveRandomInfo: NSMutableArray! = NSMutableArray()
        for dict in orderOfPlayers{
            receiveRandomInfo.addObject(dict[randomNumberKey])
        }
        if receiveRandomInfo.count == (GameCenterConnector.sharedInstance(viewc).match.playerIDs.count + 1){
            return true
        }
        return false
        
    }
    
    
    func processPlayerAliases(){
        if allRandomInfoReceived(){
            var playerAliases: NSMutableArray! = NSMutableArray(capacity: orderOfPlayers.count)
            for playerDetail in orderOfPlayers{
                var playerID: NSString! = playerDetail[playerIdKey] as NSString
                    playerAliases.addObject(GameCenterConnector.sharedInstance(viewc).playerDict[playerID]!.alias)
            }
            if playerAliases.count > 0{
                self.delegate.setPlayerAlias(playerAliases)
            }
        }
    }
    
    func match(match: GKMatch, didReceiveData data: NSData, fromPlayer playerID: NSString) {
        var message: Message!
        data.getBytes(&message, length: sizeof(Message))
        if (message.messageType == MessageType.messageTypeRandomNumber){
//            var messageOfRandomNum: MessageRandomNumber = data.getBytes(<#buffer: UnsafeMutablePointer<Void>#>, length: <#Int#>)
        }else if message.messageType == MessageType.messageTypeGameBegin{
            NSLog("Begin game")
            gameState = GameState.gameActive
            self.delegate .setCurrentPlayerIndex(indexForLocalPlayer())
            self.processPlayerAliases()
        }else if message.messageType == MessageType.messageTypeMove{
            NSLog("Move")
            // convert point
        }
        
    }
    
    func processReceivedRandomNumber(randomNumberDetails: NSDictionary){
        if orderOfPlayers.containsObject(randomNumberDetails){
            orderOfPlayers.removeObjectAtIndex(orderOfPlayers.indexOfObject(randomNumberDetails))
        }
        
        orderOfPlayers.addObject(randomNumberDetails)
        
        var sortByRandomNumber: NSSortDescriptor! = NSSortDescriptor(key: randomNumberKey, ascending: false)
        var sortDescriptors: NSArray! = [sortByRandomNumber]
        orderOfPlayers.sortUsingDescriptors(sortDescriptors)
        if (self.allRandomInfoReceived()){
            receiveAllRandomPairingNumber = true
        }
    }
    
    func indexForLocalPlayer() -> Int{
        return 0
    }
    
    func isLeftPlayer() -> Bool{
        var dictionary: NSDictionary! = orderOfPlayers[0] as NSDictionary
        //optional are no longer considerred as boolean expression
        if dictionary[playerIdKey]!.isEqualToString(GKLocalPlayer.localPlayer().playerID){
            NSLog("this is left player")
            return true
        }
        
        return false
    }
    
    func matchStarted() {
        NSLog("match start successfully")
        if receiveAllRandomPairingNumber == true{
            gameState = GameState.waitingForStart
        }else{
            gameState = GameState.waitingForRandomPairing
        }
        sendRandomPairingNumber()
        tryStartGame()
    }
    
    func matchEnded(){
        println("Match ended")
        //delegate.matchEnded()
    }

}