//
//  PreGameLobbyViewController.swift
//  QuestionTime
//
//  Created by Tim Nugent on 4/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import UIKit

class PreGameLobbyViewController: UIViewController,NetworkDelegate,AudioJiggerDelegate {
    
    var honourableMember : Int?
    var portfolio: Int?
    
    var gameStartMessage : GameStartMessage?

    override func viewDidLoad() {
        super.viewDidLoad()
        Network.sharedNetwork.delegate = self

        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"BGTile")!)
        
        // Tell the server the options the player picked
        if let theRightHonourableMember = self.honourableMember
        {
            if let thePortfolio = self.portfolio
            {
                // Sending over the player options
                Network.sharedNetwork.selectPlayerData(theRightHonourableMember, questionCategory: thePortfolio)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ServerReadySegue") {
            if let game = segue.destinationViewController as? GameViewController {
                
                game.heroID = gameStartMessage!.opponentHero
                game.possibleQuestions = gameStartMessage!.questions
                
                AudioJigger.sharedJigger.playActionMusic()
            }
        }
    }
    
    func jiggerFinishedPlayingEffect(effect: Effects) {
        if effect == Effects.Countdown
        {
            self.performSegueWithIdentifier("ServerReadySegue", sender: self)
        }
    }

    // MARK: - Network
    func networkConnected() {
        // eh, we are to be connected by now, work it out later
    }
    
    func networkDisconnected(error: NSError?) {
        // eh, worry about it later
    }
    
    func networkDidStartGame(message: GameStartMessage) {
        gameStartMessage = message
        
        // start the countdown audio playing, then jump into the game
        AudioJigger.sharedJigger.delegate = self
        AudioJigger.sharedJigger.playEffect(Effects.Countdown)
    }
    
    func networkDidEndGame(message: GameOverMessage) {
        // eh, worry about it later
    }
    
    func networkDidUpdateGameProgress(message: ProgressMessage) {
        // eh, worry about it later
    }
    


}
