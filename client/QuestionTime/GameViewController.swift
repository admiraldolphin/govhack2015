//
//  GameViewController.swift
//  QuestionTime
//
//  Created by Tim Nugent on 4/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import UIKit

class GameViewController: UIViewController,NetworkDelegate {
    
    var totalQuestions = 10
    var questionsRemaining = 0
    
    var answer : Answer = Answer.Neutral
    
    var questionID : Int?
    
    var heroID : Int = 0
    var possibleQuestions : [Int] = []

    @IBOutlet weak var questionsRemainingLabel: UILabel!
    
    @IBOutlet weak var timeRemainingProgressView: UIProgressView!

    @IBOutlet weak var voteSlider: UISlider?
    @IBOutlet weak var questionLabel: UILabel?
    
    @IBOutlet weak var yourScoreLabel: UILabel?
    @IBOutlet weak var theirScoreLabel: UILabel?
    
    var gameOverMessage : GameOverMessage?
    
    var timer : NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        possibleQuestions = [63, 51]
        heroID = 10001
        
        self.voteSlider?.setMinimumTrackImage(UIImage(named: "Empty"), forState: UIControlState.Normal)
        self.voteSlider?.setMaximumTrackImage(UIImage(named: "Empty"), forState: UIControlState.Normal)
        self.voteSlider?.setThumbImage(UIImage(named: "SelectorIndicatorTop"), forState: UIControlState.Normal)
        
        Network.sharedNetwork.delegate = self
        
        questionsRemaining = totalQuestions

        showQuestion()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(6, target: self, selector: "timeRanOut:", userInfo: nil, repeats: true)
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"BGTile")!)
    }
    
    func showQuestion() {
        // Get a topic
        
        let person = QuestionDatabase.sharedDatabase.allPeople[heroID]
        
        let policyID = possibleQuestions[Int(arc4random_uniform(UInt32(possibleQuestions.count)))]
        
        if let policy = person?.policies[policyID] {
            self.questionLabel?.text = policy.name
            
            self.questionID = policyID
            
            self.answer = Answer.Neutral
            
            self.voteSlider?.value = 0.5
            
            self.timeRemainingProgressView?.progress = 1.0

            CATransaction.begin()
            CATransaction.setAnimationDuration(6.0)
            self.timeRemainingProgressView?.setProgress(0.0, animated: true)
            CATransaction.commit()
            
            self.questionsRemainingLabel?.text = "\(self.questionsRemaining) questions remaining"
            
            // adding the question to the asked questions list
            if let theQuestionID = self.questionID
            {
                QuestionDatabase.sharedDatabase.askedQuestions.append(theQuestionID)
            }
        }
        
        // firing up the 6 second ticking audio
        AudioJigger.sharedJigger.playEffect(.Ticking)
    }
    
    func timeRanOut(sender:AnyObject)
    {

        Network.sharedNetwork.submitAnswer(self.questionID!, answer: answer)
        
        self.questionsRemaining -= 1
        
        if (self.questionsRemaining > 0) {
            showQuestion()
        } else {
            // Wait for the server to tell us to go to the game over screen
            
            timer?.invalidate()
        }
        
        
    }
    
    @IBAction func voteSliderValueChange(sender: AnyObject) {
        answer = Answer.fromFloat(self.voteSlider?.value ?? 0.0)
    }
    
    @IBAction func abstainVote(sender: AnyObject) {
        answer = Answer.Abstain
    }
    
    // MARK: - Network
    func networkConnected() {
        // don't care
    }
    
    func networkDisconnected(error: NSError?) {
        // through up an error and pop back to lobby
    }
    
    func networkDidStartGame(message: GameStartMessage) {
        // don't care
    }
    
    func networkDidEndGame(message: GameOverMessage) {
        // throw us back to lobby
        gameOverMessage = message
        self.performSegueWithIdentifier("GameOverSegue", sender: self)
    }
    
    func networkDidUpdateGameProgress(message: ProgressMessage) {
        // ok here is what we care about
        // later on we should show some sort of indication as to how right/wrong they were
        
        self.yourScoreLabel?.text = "Your Score: \(message.yourScore)"
        self.theirScoreLabel?.text = "Their Score: \(message.opponentScore)"
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "GameOverSegue"
        {
            if let theDestination = segue.destinationViewController as? GameOverLobbyViewController
            {
                theDestination.youWon = gameOverMessage?.youWon ?? false
            }
        }
    }

}
