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

class Network: NSObject, GCDAsyncSocketDelegate {
    
    var socket : GCDAsyncSocket
    
    var gameState = GameState.NotConnected
    
    init?(host: String, port: UInt16) {
        
        socket = GCDAsyncSocket()
        
        super.init()
        
        socket.delegate = self
        socket.delegateQueue = dispatch_get_main_queue()
        
        var error : NSError?
        socket.connectToHost(host, onPort: port, error: &error)
        
        if (error != nil) {
            return nil
        }
    }
    
    func sendMessage(message:String) {
        assert(socket.isConnected)
        
        let data = (message+"\n\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        socket.writeData(data, withTimeout: 2.0, tag: 0)
    }
    
    func listenForNewData() {
        socket.readDataToData(GCDAsyncSocket.LFData(), withTimeout: -1, tag:0)
    }
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        println("Connected!")
        
        gameState = .Lobby
        
        sendMessage("Hi")
        
        listenForNewData()
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        let string = NSString(data: data, encoding: NSUTF8StringEncoding)
        println("Read: \(string)")
        
        listenForNewData()
    }
    
    func selectPlayerData(politician: String, questionCategory: String) {
        // Send 'here's my MP and category'
    }
    
    func updateAnswerStats(answeredCorrectly: Bool) {
        // Send "I answered a question correctly/incorrectly"
    }

    
   
    
}