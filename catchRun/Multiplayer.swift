//
//  Multiplayer.swift
//  catchRun
//
//  Created by Li, Xiaoping on 12/21/14.
//  Copyright (c) 2014 LUSS. All rights reserved.
//

import Foundation
import GameKit

// for this class, there is api for sending info to game center: such as sendMove(), sendRandomPairingnum(), sendGameOver)_
// there is also api for receiving info from game center: such as match(:didReceivedData; fromPlayerID), it deals all the situation, such as player moving info, prepare to start game info, pairing info.



protocol MultiplayerProtocol{
    func matchEnded()
    func setCurrentPlayerIndex(index: Int)
    func movePlayerAtIndex(position: CGPoint, id: String)
    func gameOver(leftWon: Bool)
    func setPlayerAlias(playerAliases: NSArray)
    //func setPlayerRole(selfRand: Int, remoteDictRand: Dictionary<String, Int>)
    
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
    var randomNumber: Double
}

struct MessageGameBegin{
    var message: Message
}


struct MessageMove{
    // in move message, we need a direction
    var message: Message
    var position: CGPoint
}

struct MessageGameOver{
    var message: Message
    var leftWon: Bool
}

let gameBegin : String! = "game begin"
class Multiplayer: NSObject, GameConnectorDelegate{
    
    var receiveAllRandomPairingNumber: Bool?
    //gamestate initiall should be waiting for a match connection to be established
    var gameState = GameState.waitingForMatch
    var randomNumber = Double(arc4random())
    var orderOfPlayers = Dictionary<String, Double>()
    var delegate: MultiplayerProtocol!
    let playerIdKey: String! = "playerID"
    let randomNumberKey: String! = "randomNumber"
    
    //orderOfPlayers is made up by key randomnumber and value localplayerID.
    override init(){
        super.init()
        orderOfPlayers[GKLocalPlayer.localPlayer().playerID as String] = self.randomNumber;
    }
    
    // CALLED BY METHOD LOOKUPPLAYER() IN GAMECENTERCONNECTOR
    //if receive all random number, set game state for waiting for start
    func matchStarted() {
        NSLog("auto match connect successfully, check for current game state \n")
        //DETECT WHETHER RECEIVE OTHER PEOPLE'S RANDOM NUMBER
        if receiveAllRandomPairingNumber != nil && receiveAllRandomPairingNumber == true{
            NSLog("game wait to start \n")
            gameState = GameState.waitingForStart
        }else{
            NSLog("game wait for remote player's random number \n")
            gameState = GameState.waitingForRandomPairing
        }
        // SEND ITS OWN RANDOM NUMBER
        sendRandomPairingNumber()
        tryStartGame()
    }
    
    //try to start game
    func tryStartGame(){
        if gameState == GameState.waitingForStart{
            gameState = GameState.gameActive
            self.sendGameBegin()
            NSNotificationCenter.defaultCenter().postNotificationName(gameBegin, object: nil)
            //self.delegate.setCurrentPlayerIndex(0)
            //self.processPlayerAliases()
            NSLog("send out game begin message")
        }
    }
    
    //send data information to players in the match connection
    //all kinds of data: sending random number info, sending moving index info and so on
    func sendData(data: NSData){
        var error:NSError?;
        //get the shared instance of gamecenterconnector
        var gameConnector: GameCenterConnector = GameCenterConnector.sharedInstance()
        //transmit data to all players in the match, use GKMatchSendDataMode.Reliable can make sure
        //other player receive all data.
        var success: Bool! = gameConnector.match.sendDataToAllPlayers(data, withDataMode: GKMatchSendDataMode.Reliable, error: &error)
        //if not success, which means player is not connected, and game should end
        if (!success){
            println(error?.localizedDescription)
            matchEnded()
        }
    }
    
    // send move infomation to game center, add id
    func sendMove(position: CGPoint, id: String){
       // NSLog("send move message")
//        let dataid = (id as NSString).dataUsingEncoding(NSUTF8StringEncoding)
//        NSLog("send move position \(position) with id \(id)")
        var messageMove = MessageMove(message: Message(messageType: MessageType.messageTypeMove), position: position)
        var data = encode(messageMove)
        sendData(data)
    }
    
    
    func encode<T>(var value: T) -> NSData {
        return withUnsafePointer(&value) { p in
            NSData(bytes: p, length: sizeofValue(value))
        }
    }
    
    func decode<T>(data: NSData) -> T {
        let pointer = UnsafeMutablePointer<T>.alloc(sizeof(T.Type))
        data.getBytes(pointer)
        
        return pointer.move()
    }

    
    //cast randomMessage to NSData, send it to other player
    func sendRandomPairingNumber(){
        NSLog("send my random number %d", self.randomNumber)
        var message = MessageRandomNumber(message: Message(messageType: MessageType.messageTypeRandomNumber), randomNumber: self.randomNumber)
        //        var message: MessageRandomNumber!
        //        message.message.messageType = MessageType.messageTypeRandomNumber
        //        message.randomNumber = self.randomNumber
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
        NSLog("send begin message")
        var message = MessageGameBegin(message: Message(messageType: MessageType.messageTypeGameBegin))
        var data = NSData(bytes: &message, length: sizeof(MessageGameBegin))
        sendData(data)
    }
    
//    func processPlayerAliases(){
//        if allRandomInfoReceived(){
//            var playerAliases: NSMutableArray! = NSMutableArray(capacity: orderOfPlayers.count)
//            for playerDetail in orderOfPlayers{
//                var playerID: NSString! = playerDetail[playerIdKey] as NSString
//                playerAliases.addObject(GameCenterConnector.sharedInstance().playerDict[playerID]!.alias)
//            }
//            if playerAliases.count > 0{
//                self.delegate.setPlayerAlias(playerAliases)
//            }
//        }
//    }
    
    //change incoming data to message structure
    //this method is used for decoding incoming game data
    func match(match: GKMatch, didReceiveData data: NSData, fromPlayer playerID: NSString) {
        var message: Message!
        data.getBytes(&message, length: sizeof(Message))
        if (message.messageType == MessageType.messageTypeRandomNumber){
            var messageOfRandomNum: MessageRandomNumber!
            //write data into messageOfRandomNum buffer
            data.getBytes(&messageOfRandomNum,
                length: sizeof(MessageRandomNumber))
            NSLog("Receive random number\(messageOfRandomNum.randomNumber) \n")
            var tie: Bool! = false
            if messageOfRandomNum.randomNumber == randomNumber{
                NSLog("tie")
                tie = true
                randomNumber = Double(arc4random())
                sendRandomPairingNumber()
            }else{
                var dictionary: NSDictionary! = [playerIdKey as String: playerID as String, randomNumberKey: messageOfRandomNum.randomNumber]
                orderOfPlayers[playerID as String] = messageOfRandomNum.randomNumber
                processReceivedRandomNumber(dictionary)
            }
            if receiveAllRandomPairingNumber == true{
                NSLog("receive all number")
                
            }
            if (!tie && receiveAllRandomPairingNumber == true){
                //hacky way for two users
          //      self.delegate.setPlayerRole(self.randomNumber, remoteDictRand: [playerID: messageOfRandomNum.randomNumber])
                if gameState == GameState.waitingForRandomPairing{
                    gameState = GameState.waitingForStart
                }
                tryStartGame()
            }
            
        }else if message.messageType == MessageType.messageTypeGameBegin{
//            NSLog("other player begin game")
            gameState = GameState.gameActive
            //self.delegate.setCurrentPlayerIndex(indexForLocalPlayer())
            //self.processPlayerAliases()
        }else if message.messageType == MessageType.messageTypeMove{
            var whole_message: MessageMove = decode(data)
//            NSLog("******* receive position \(whole_message.position) with id \(playerID)")
            
            self.delegate.movePlayerAtIndex(whole_message.position, id: playerID as String)
            
//            NSLog("receive Move message")

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

        if (self.allRandomInfoReceived()){
            receiveAllRandomPairingNumber = true
        }
    }
    
    //check from order of players
    func allRandomInfoReceived() -> Bool{

        if orderOfPlayers.count == (GameCenterConnector.sharedInstance().match.playerIDs.count + 1){
            return true
        }
        return false
    }
    
    
    
    func matchEnded(){
        println("Match ended")
        //delegate.matchEnded()
    }
    
    func getRandomNumber() -> Dictionary<String, Double>{
        return orderOfPlayers
    }
    
}