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
    func movePlayerAtIndex(index: Int, direction: String)
    func gameOver(leftWon: Bool)
    func setPlayerAlias(playerAliases: NSArray)
}
// we need separate game state
enum GameState: Int{
    //waiting for a match to be connected, maybe call waiting for connection is clear
    case waitingForMatch = 0
    //waiting for random number assigned to this player
    case waitingForRandomPairing
    //waiting for game start
    case waitingForStart
    //active playing in the game
    case gameActive
    //game finish
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
    // in move message, we need a direction
    var direction: String
    var message: Message
}

struct MessageGameOver{
    var message: Message
    var leftWon: Bool
}

class Multiplayer: NSObject, GameConnectorDelegate{
    
    var receiveAllRandomPairingNumber: Bool!
    //use P1 to denote police
    var isP1: Bool!
    var gameState: GameState!
    var randomNumber: Int!
    var orderOfPlayers: NSMutableArray!
    var delegate: MultiplayerProtocol!
    let playerIdKey: String! = "playerID"
    var viewc: UIViewController!
    let randomNumberKey: String! = "randomNumber"
    
    init(viewc: UIViewController){
        super.init()
        self.viewc = viewc
        randomNumber = Int(arc4random())
        //gamestate initiall should be waiting for a match connection to be established
        gameState = GameState.waitingForMatch
        orderOfPlayers = NSMutableArray()
        var dic = [playerIdKey as String: GKLocalPlayer.localPlayer().playerID as String, randomNumberKey: randomNumber]
        orderOfPlayers.addObject(dic)
    }
    
    //if receive all random number, set game state for waiting for start
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
    
    //send data information to players in the match connection
    //all kinds of data: sending random number info, sending moving index info and so on
    func sendData(data: NSData){
        var error:NSError?;
        //get the shared instance of gamecenterconnector
        var gameConnector: GameCenterConnector = GameCenterConnector.sharedInstance(viewc)
        //transmit data to all players in the match, use GKMatchSendDataMode.Reliable can make sure
        //other player receive all data.
        var success: Bool! = gameConnector.match.sendDataToAllPlayers(data, withDataMode: GKMatchSendDataMode.Reliable, error: &error)
        //if not success, which means player is not connected, and game should end
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
    

    //cast randomMessage to NSData, send it to other player
    func sendRandomPairingNumber(){
        var message: MessageRandomNumber!
        message.message.messageType = MessageType.messageTypeRandomNumber
        message.randomNumber = self.randomNumber
        var data = NSData(bytes: &message, length: sizeof(MessageRandomNumber))
        sendData(data)
    }
    
    
    func sendGameEnd(leftWon: Bool){
        var message : MessageGameOver!
        message.message.messageType = MessageType.messageTypeGameOver
        message.leftWon = leftWon
        var data = NSData(bytes: &message, length: sizeof(MessageGameOver))
        sendData(data)
    }
    
    //send gamebegin data to other player
    func sendGameBegin(){
        var message: MessageGameBegin!
        message.message.messageType = MessageType.messageTypeGameBegin
        var data = NSData(bytes: &message, length: sizeof(MessageGameBegin))
        sendData(data)
    }
    //try to start game
    func tryStartGame(){
        if isP1 == true && gameState == GameState.waitingForStart{
           gameState = GameState.gameActive
            self.sendGameBegin()
            self.delegate.setCurrentPlayerIndex(0)
            self.processPlayerAliases()
        }
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
    
    //change incoming data to message structure
    func match(match: GKMatch, didReceiveData data: NSData, fromPlayer playerID: NSString) {
        var message: Message!
        data.getBytes(&message, length: sizeof(Message))
        if (message.messageType == MessageType.messageTypeRandomNumber){
            var messageOfRandomNum: MessageRandomNumber!
            //write data into messageOfRandomNum buffer
            data.getBytes(&messageOfRandomNum, length: sizeof(MessageRandomNumber))
            NSLog("Receive random number: %d", messageOfRandomNum.randomNumber)
            var tie: Bool! = false
            if messageOfRandomNum.randomNumber == randomNumber{
                NSLog("tie")
                tie = true
                randomNumber = Int(arc4random())
                sendRandomPairingNumber()
            }else{
                var dictionary: NSDictionary! = [playerIdKey as String: playerID as String, randomNumberKey: messageOfRandomNum.randomNumber]
                processReceivedRandomNumber(dictionary)
            }
            if receiveAllRandomPairingNumber == true{
                isP1 = isLeftPlayer()
            }
            if (!tie && receiveAllRandomPairingNumber == true){
                if gameState == GameState.waitingForRandomPairing{
                    gameState = GameState.waitingForStart
                }
                tryStartGame()
            }
            
        }else if message.messageType == MessageType.messageTypeGameBegin{
            NSLog("Begin game")
            gameState = GameState.gameActive
            self.delegate .setCurrentPlayerIndex(indexForLocalPlayer())
            self.processPlayerAliases()
        }else if message.messageType == MessageType.messageTypeMove{
            NSLog("Move")
            var messageMove: MessageMove!
            data.getBytes(&messageMove, length: sizeof(MessageMove))
            //get playerindex and direction
            self.delegate.movePlayerAtIndex(indexForPlayerID(playerID), direction: messageMove.direction)
            // convert point
        }else if message.messageType == MessageType.messageTypeGameOver{
            NSLog("Game Over")
            var messageGameOver: MessageGameOver!
            data.getBytes(&messageGameOver, length: sizeof(MessageGameOver))
            self.delegate.gameOver(messageGameOver.leftWon)
        }
        
    }
    
    //make the highest random number to be police
    //lower random number denotes the thief
    func processReceivedRandomNumber(randomNumberDetails: NSDictionary){
        if orderOfPlayers.containsObject(randomNumberDetails){
            orderOfPlayers.removeObjectAtIndex(orderOfPlayers.indexOfObject(randomNumberDetails))
        }
        
        orderOfPlayers.addObject(randomNumberDetails)
        
        var sortByRandomNumber: NSSortDescriptor! = NSSortDescriptor(key: randomNumberKey, ascending: false)
        var sortDescriptors: NSArray! = [sortByRandomNumber]
        orderOfPlayers.sortUsingDescriptors(sortDescriptors)
        if (self.allRandomInfoReceived()){
            receiveAllRandomPairingNumber! = true
        }
    }
    
    func allRandomInfoReceived() -> Bool{
        var receiveRandomInfo: NSMutableArray! = NSMutableArray()
        for dict in orderOfPlayers{
            receiveRandomInfo.addObject(dict[randomNumberKey])
        }
        //var arrayOfUniqueRandomNum: NSArray! = NSSet(receivedRandomNumbers) allObjects
        if receiveRandomInfo.count == (GameCenterConnector.sharedInstance(viewc).match.playerIDs.count + 1){
            return true
        }
        return false
    }
    
    func indexForLocalPlayer() -> Int{
        var playerId: NSString! = GKLocalPlayer.localPlayer().playerID
        return indexForPlayerID(playerId)
    }
    
    func indexForPlayerID(playerId: NSString) -> Int{
        var index: Int = -1
        orderOfPlayers.enumerateObjectsUsingBlock { (obj, idx, stop) -> Void in
            var pId: NSString! = obj[self.playerIdKey] as NSString
            if pId.isEqualToString(playerId){
                index = idx
                stop.initialize(true)
            }
        }
        return index
    }
    
    //P1 player
    func isLeftPlayer() -> Bool{
        var dictionary: NSDictionary! = orderOfPlayers[0] as NSDictionary
        //optional are no longer considerred as boolean expression
        if dictionary[playerIdKey]!.isEqualToString(GKLocalPlayer.localPlayer().playerID){
            NSLog("this is P1")
            return true
        }
        return false
    }
    
    func matchEnded(){
        println("Match ended")
        //delegate.matchEnded()
    }

}