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

protocol NetworkDelegate {
    func networkConnected()
    func networkDisconnected(error: NSError?)
    func networkStateChanged(oldState: GameState, newState:GameState, context:[String:AnyObject])
}

class Network: NSObject, GCDAsyncSocketDelegate {
    
    static var sharedNetwork = {
        return Network()
    }()
    
    var socket = GCDAsyncSocket()
    
    var delegate : NetworkDelegate?
    
    var gameState = GameState.NotConnected
    
    override init() {
        super.init()
    }
    
    func connect(host:String, port:UInt16) {
        socket = GCDAsyncSocket()
        
        socket.delegate = self
        socket.delegateQueue = dispatch_get_main_queue()
        
        var error : NSError?
        socket.connectToHost(host, onPort: port, error: &error)
    }
    
    
    func sendMessage(message:String) {
        assert(socket.isConnected)
        
        let data = (message+"\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        socket.writeData(data, withTimeout: 2.0, tag: 0)
    }
    
    func listenForNewData() {
        socket.readDataToData(GCDAsyncSocket.LFData(), withTimeout: -1, tag:0)
    }
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        println("Connected!")
        
        gameState = .Lobby
        
        delegate?.networkConnected()
        
        listenForNewData()
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        let string = NSString(data: data, encoding: NSUTF8StringEncoding)
        println("Read: \(string)")
        
        // Parse the response into json
        let loadedData = JSON(data: data)
        
        let type : JSON = loadedData["Type"]
        
        println("Received a message of type \(type)")
        
        listenForNewData()
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        delegate?.networkDisconnected(err)
    }
    
    func selectPlayerData(politician: String, questionCategory: String) {
        
        var data = [
            "Type":"Player",
            "HeroPick":politician,
            "PortfolioPick":questionCategory
        ]
        
        var json = JSON(data)
        
        sendMessage(json.rawString(encoding: NSUTF8StringEncoding, options: NSJSONWritingOptions.allZeros)!)
        
        // Send 'here's my MP and category'
    }
    
    func updateAnswerStats(answeredCorrectly: Bool) {
        // Send "I answered a question correctly/incorrectly"
    }
    
}