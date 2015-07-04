//
//  PreGameLobbyViewController.swift
//  QuestionTime
//
//  Created by Tim Nugent on 4/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import UIKit

class PreGameLobbyViewController: UIViewController,NetworkDelegate {
    
    var honourableMember : String?
    var portfolio: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        Network.sharedNetwork.delegate = self

        
        // Tell the server the options the palyer picked
        if let theRightHonourableMember = self.honourableMember
        {
            if let thePortfolio = self.portfolio
            {
                Network.sharedNetwork.selectPlayerData(theRightHonourableMember, questionCategory: thePortfolio)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Network
    func networkConnected() {
        // eh, we are to be connected by now, work it out later
    }
    func networkDisconnected(error: NSError?) {
        // eh, worry about it later
    }
    func networkStateChanged(oldState: GameState, newState: GameState, context: [String : AnyObject]) {
        // ok we need to know when the state has changed to the ready state which is inGame
        
        if newState == GameState.InGame
        {
            self.performSegueWithIdentifier("ServerReadySegue", sender: self)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
