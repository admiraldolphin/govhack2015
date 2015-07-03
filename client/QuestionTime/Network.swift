//
//  Network.swift
//  QuestionTime
//
//  Created by Jon Manning on 3/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import Foundation

enum NetworkConnectionState : UInt {
    case NotConnected
    case Connected
    
}

typealias StateChangeHandler = NetworkConnectionState -> Void

class Network: NSObject, NSStreamDelegate {
    
    private var stateChangeHandler : StateChangeHandler
    
    private var outputStream : NSOutputStream?
    private var inputStream : NSInputStream?
    
    var state = NetworkConnectionState.NotConnected {
        didSet {
            stateChangeHandler(state)
        }
    }
    
    init(host:String, port:Int, stateChangeHandler:StateChangeHandler) {
        
        self.stateChangeHandler = stateChangeHandler
        
        NSStream.getStreamsToHostWithName(host,
            port: port,
            inputStream: &inputStream,
            outputStream: &outputStream)
        
        
        
        super.init()
        
        self.inputStream!.delegate = self
        self.outputStream!.delegate = self
        
        self.inputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        self.outputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        self.inputStream!.open()
        self.outputStream!.open()
        
        
        
    }
    
    func sendMessage(message: String) {
        assert(state != .NotConnected)
        
        if let data = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
            outputStream?.write(UnsafePointer(data.bytes), maxLength: data.length)
            
            
        }
        
        
    }
    
    func stream(stream: NSStream, handleEvent eventCode: NSStreamEvent) {
        println("stream event: \(eventCode)")
        
        switch state {
        case .NotConnected:
            if eventCode == NSStreamEvent.OpenCompleted {
                if inputStream!.streamStatus  == NSStreamStatus.Open &&
                    outputStream!.streamStatus == NSStreamStatus.Open {
                        state = .Connected
                        
                        
                        
                }
            }
        default:
            ()
        }
        
    }
    
    
    
    
    
    
    
   
    
}