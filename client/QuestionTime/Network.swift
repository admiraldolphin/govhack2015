//
//  Network.swift
//  QuestionTime
//
//  Created by Jon Manning on 3/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import Foundation
import UIKit

enum NetworkConnectionState : UInt {
    case NotConnected
    case Connected
    
}

typealias StateChangeHandler = NetworkConnectionState -> Void

class Network: NSObject, GCDAsyncSocketDelegate {
    
    var socket : GCDAsyncSocket
    
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
        
        let data = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        //socket.writeData(<#data: NSData!#>, withTimeout: <#NSTimeInterval#>, tag: <#Int#>)
    }
    
    private func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        println("Connected!")
        
        
    }
   
    
}