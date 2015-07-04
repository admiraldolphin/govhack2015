//
//  Network.swift
//  QuestionTime
//
//  Created by Jon Manning on 3/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import Foundation
import UIKit


enum GameState : UInt {
    case NotConnected
    case Lobby
    case LobbyWaiting
    case InGame
    case InGameWaiting
    case GameOver
    
}

enum Answer : Int {
    case DisagreeStrong = 1
    case Disagree       = 2
    case Neutral        = 3
    case Agree          = 4
    case AgreeStrong    = 5
    case Abstain        = -1
}

// Messages from server

struct HelloMessage {
    // contains nothing
}

struct GameStartMessage {
    var OpponentHero : Int
    var PortfolioName : String
    var Questions : [Int]
}

struct ProgressMessage {
    var YourScore : Int
    var OpponentScore : Int
}

struct KeepAliveMessage {
    // contains nothing
}

struct GameOverMessage {
    var YouWon : Bool
}

protocol NetworkDelegate {
    func networkConnected()
    func networkDisconnected(error: NSError?)
    func networkStateChanged(oldState: GameState, newState:GameState, context:[String:AnyObject])
}

class Network: NSObject, GCDAsyncSocketDelegate {
    
    static var sharedNetwork = {
        return Network()
    }()
    
    let port : UInt16 = 8888
    
    var socket = GCDAsyncSocket()
    
    var delegate : NetworkDelegate?
    
    var gameState = GameState.NotConnected
    
    override init() {
        super.init()
    }
    
    func connect(host:String) {
        socket = GCDAsyncSocket()
        
        socket.delegate = self
        socket.delegateQueue = dispatch_get_main_queue()
        
        var error : NSError?
        socket.connectToHost(host, onPort: self.port, error: &error)
    }
    
    
    func sendMessage(message:String) {
        assert(socket.isConnected)
        
        println(message)
        
        let data = (message+"\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        socket.writeData(data, withTimeout: 2.0, tag: 0)
    }
    
    func listenForNewData() {
        socket.readDataToData(GCDAsyncSocket.LFData(), withTimeout: -1, tag:0)
    }
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        println("Connected!")
        
        gameState = .Lobby
        
        updateName()
        
        delegate?.networkConnected()
        
        
        
        listenForNewData()
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        let string = NSString(data: data, encoding: NSUTF8StringEncoding)
        println("Read: \(string)")
        
        // Parse the response into json
        let loadedData = JSON(data: data)
        
        let type : JSON = loadedData["Type"]
        
        listenForNewData()
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        delegate?.networkDisconnected(err)
    }
    
    func selectPlayerData(politician: Int, questionCategory: Int) {
        
        var data = [
            "Type":"Player",
            "Data":[
                "HeroPick":politician,
                "PortfolioPick":questionCategory
            ]
        ]
        
        var json = JSON(data)
        
        sendMessage(json.rawString(encoding: NSUTF8StringEncoding, options: NSJSONWritingOptions.allZeros)!)
        
        // Send 'here's my MP and category'
    }
    
    func updateAnswerStats(questionID: Int, answer: Answer) {
        
        var data = [
            "Type":"Answer",
            "Data":[
                "Question":questionID,
                "Answer": answer.rawValue
            ]
        ]
        
        var json = JSON(data)
        sendMessage(json.rawString(encoding: NSUTF8StringEncoding, options: NSJSONWritingOptions.allZeros)!)
        
        // Send "I answered a question correctly/incorrectly"
    }
    
    private func updateName() {
        
        var data = [
            "Type":"Nickname",
            "Data":[
                "Name":UIDevice.currentDevice().name
            ]
        ]
        
        var json = JSON(data)
        sendMessage(json.rawString(encoding: NSUTF8StringEncoding, options: NSJSONWritingOptions.allZeros)!)
        
    }
    
}