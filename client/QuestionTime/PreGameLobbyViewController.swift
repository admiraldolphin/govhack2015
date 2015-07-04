//
//  PreGameLobbyViewController.swift
//  QuestionTime
//
//  Created by Tim Nugent on 4/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import UIKit

class PreGameLobbyViewController: UIViewController,NetworkDelegate {
    
    var honourableMember : Int?
    var portfolio: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        Network.sharedNetwork.delegate = self

        
        // Tell the server the options the palyer picked
        if let theRightHonourableMember = self.honourableMember
        {
            if let thePortfolio = self.portfolio
            {
                // FIX THIS
                Network.sharedNetwork.selectPlayerData(1, questionCategory: 1)
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
    func networkDidStartGame(message: GameStartMessage) {
        self.performSegueWithIdentifier("ServerReadySegue", sender: self)
    }
    func networkDidEndGame(message: GameOverMessage) {
        // eh, worry about it later
    }
    func networkDidUpdateGameProgress(message: ProgressMessage) {
        // eh, worry about it later
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
