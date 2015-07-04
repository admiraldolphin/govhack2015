//
//  Network.swift
//  QuestionTime
//
//  Created by Jon Manning on 3/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import Foundation
import UIKit


enum Answer : Int {
    case DisagreeStrong = 1 // 0  - 20
    case Disagree       = 2 // 20 - 40
    case Neutral        = 3 // 40 - 60
    case Agree          = 4 // 60 - 80
    case AgreeStrong    = 5 // 80 - 100
    case Abstain        = -1
    
    static func fromFloat(float:Float) -> Answer {
        switch float {
        case 0.0...0.2:
            return Answer.DisagreeStrong
        case 0.2...0.4:
            return Answer.Disagree
        case 0.4...0.6:
            return Answer.Neutral
        case 0.6...0.8:
            return Answer.Agree
        case 0.8...1.0:
            return Answer.AgreeStrong
        default:
            return Answer.Abstain
        }
    }
}

// Messages from server

struct HelloMessage {
    // contains nothing
}

struct GameStartMessage {
    var opponentHero : Int
    var portfolioName : String
    var questions : [Int]
}

struct ProgressMessage {
    var yourScore : Int
    var opponentScore : Int
}

struct KeepAliveMessage {
    // contains nothing
}

struct GameOverMessage {
    var youWon : Bool
}

protocol NetworkDelegate {
    func networkConnected()
    func networkDisconnected(error: NSError?)
    
    func networkDidStartGame(message: GameStartMessage)
    func networkDidEndGame(message: GameOverMessage)
    func networkDidUpdateGameProgress(message: ProgressMessage)
}

class Network: NSObject, GCDAsyncSocketDelegate {
    
    static var sharedNetwork = {
        return Network()
    }()
    
    let port : UInt16 = 8888
    
    var socket = GCDAsyncSocket()
    
    var delegate : NetworkDelegate?
    
    var timer : NSTimer?
    
    override init() {
        
        super.init()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "sendKeepalive:", userInfo: nil, repeats: true)
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func sendKeepalive(timer: NSTimer) {
        if socket.isConnected {
            let data = [
                "Type":"Keepalive",
                "Data":["foo":"bar"]
            ]
            sendMessage(JSON(data).rawString(encoding: NSUTF8StringEncoding, options: NSJSONWritingOptions.allZeros)!)
        }
    }
    
    func connect() {
        let host = NSUserDefaults.standardUserDefaults().stringForKey("server") ?? "localhost"
        
        connect(host)
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
        
        println("Sending: \(message)")
        
        let data = (message+"\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        socket.writeData(data, withTimeout: 2.0, tag: 0)
    }
    
    func listenForNewData() {
        socket.readDataToData(GCDAsyncSocket.LFData(), withTimeout: -1, tag:0)
    }
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        println("Connected!")
        
        updateName()
        
        delegate?.networkConnected()
        
        listenForNewData()
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
            
            println("Read: \(string)")
            
            // Parse the response into json
            let loadedData = JSON(data: data)
            
            switch loadedData["Type"].stringValue {
            case "GameStart":
                receivedGameStart(loadedData["Data"])
            case "Progress":
                receivedProgress(loadedData["Data"])
            case "GameOver":
                receivedGameOver(loadedData["Data"])
            default:
                ()
            }
        }
        
        listenForNewData()
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        delegate?.networkDisconnected(err)
    }
    
    func selectPlayerData(politician: Int, questionCategory: Int) {
        
        // Send 'here's my MP and category'
        
        var data = [
            "Type":"Player",
            "Data":[
                "HeroPick":politician,
                "PortfolioPick":questionCategory
            ]
        ]
        
        var json = JSON(data)
        
        sendMessage(json.rawString(encoding: NSUTF8StringEncoding, options: NSJSONWritingOptions.allZeros)!)
        
        
    }
    
    func submitAnswer(questionID: Int, answer: Answer) {
        
        // Send "I answered a question correctly/incorrectly"
        
        var data = [
            "Type":"Answer",
            "Data":[
                "Question":questionID,
                "Answer": answer.rawValue
            ]
        ]
        
        var json = JSON(data)
        sendMessage(json.rawString(encoding: NSUTF8StringEncoding, options: NSJSONWritingOptions.allZeros)!)
        
        
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
    
    private func receivedGameStart(data:JSON) {
        
        let message = GameStartMessage(opponentHero: data["OpponentHero"].intValue,
            portfolioName: data["PortfolioName"].stringValue,
            questions: (data["Questions"].arrayObject as! [Int]))
        
        delegate?.networkDidStartGame(message)
        
    }
    
    private func receivedGameOver(data:JSON) {
        
        let message = GameOverMessage(youWon: data["YouWon"].boolValue)
        
        delegate?.networkDidEndGame(message)
        
    }
    
    private func receivedProgress(data:JSON) {
        
        let message = ProgressMessage(yourScore: data["YourScore"].intValue,
            opponentScore: data["OpponentScore"].intValue)
        
        delegate?.networkDidUpdateGameProgress(message)
        
    }
    
}