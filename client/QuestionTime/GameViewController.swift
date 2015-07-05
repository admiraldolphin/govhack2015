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
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var bodyImageView: UIImageView!
    var answer : Answer = Answer.Neutral
    
    var questionID : Int?
    
    var heroID : Int = 0
    var possibleQuestions : [Int] = []

    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var questionsRemainingLabel: UILabel!
    
    @IBOutlet weak var timeRemainingProgressView: UIProgressView!

    @IBOutlet weak var voteSlider: UISlider?
    @IBOutlet weak var questionLabel: UILabel?
    
    @IBOutlet weak var yourScoreLabel: UILabel?
    @IBOutlet weak var theirScoreLabel: UILabel?
    

    @IBOutlet weak var spinningView: CERoundProgressView!
    
    var gameOverMessage : GameOverMessage?
    
    var timer : NSTimer?
    
    @IBOutlet weak var indicatorStronglyAgree: UIImageView!
    @IBOutlet weak var indicatorNeutral: UIImageView!
    @IBOutlet weak var indicatorDisagree: UIImageView!
    @IBOutlet weak var indicatorAgree: UIImageView!
    @IBOutlet weak var indicatorStronglyDisagree: UIImageView!
    
    @IBOutlet weak var abstainButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.voteSlider?.setMinimumTrackImage(UIImage(named: "Empty"), forState: UIControlState.Normal)
        self.voteSlider?.setMaximumTrackImage(UIImage(named: "Empty"), forState: UIControlState.Normal)
        self.voteSlider?.setThumbImage(UIImage(named: "SelectorIndicatorTop"), forState: UIControlState.Normal)
        
        Network.sharedNetwork.delegate = self
        
        questionsRemaining = totalQuestions

        showQuestion()
        
        if let person = QuestionDatabase.sharedDatabase.allPeople[heroID] {
            
            let text = "How does \(person.name) feel about..."
            self.personNameLabel?.text = text
            
            switch person.gender {
            case .Male:
                self.bodyImageView.image = UIImage(named: "BodyIdleMale")
            case .Female:
                self.bodyImageView.image = UIImage(named: "BodyIdleFemale")
            default:
                ()
            }
            
            self.headImageView.image = UIImage(named: "\(person.id)")
        }
        
        
        
        
        
        timer = NSTimer.scheduledTimerWithTimeInterval(6, target: self, selector: "timeRanOut:", userInfo: nil, repeats: true)
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"BGTile")!)
        
        rotateClock()
    }
    
    func rotateClock()
    {
        self.spinningView.animationDuration = 6
        self.spinningView.startAngle = Float(M_PI_2)
        self.spinningView.tintColor = UIColor.grayColor()
        self.spinningView.progress = 1
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
            
            // firing up the 6 second ticking audio
            AudioJigger.sharedJigger.playEffect(.Ticking)
        } else {
            // whoa we have no policy? try again
            showQuestion()
        }
        
        
    }
    
    func timeRanOut(sender:AnyObject)
    {

        let correctAnswer = QuestionDatabase.sharedDatabase.correctAnswerForPerson(heroID, policyID: self.questionID!)
        
        switch correctAnswer {
        case .Abstain:
            ()
        case .AgreeStrong:
            ()
        case .Agree:
            ()
        case .Neutral:
            ()
        case .Disagree:
            ()
        case .DisagreeStrong:
            ()
        }
        
        if correctAnswer == answer {
            AudioJigger.sharedJigger.playEffect(Effects.HereHere)
        } else {
            AudioJigger.sharedJigger.playEffect(Effects.Booing)
        }
        
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
            timer?.invalidate()
            if let theDestination = segue.destinationViewController as? GameOverLobbyViewController
            {
                theDestination.youWon = gameOverMessage?.youWon ?? false
            }
        }
    }

}
