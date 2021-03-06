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
    
    @IBOutlet weak var theirScoreHeight: NSLayoutConstraint!
    @IBOutlet weak var myScoreHeight: NSLayoutConstraint!
    let minScoreHeight = 186
    let maxScoreHeight = 350
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var bodyImageView: UIImageView!
    var answer : Answer = Answer.Neutral
    
    var questionID : Int?
    
    var heroID : Int = 0
    var possibleQuestions : [Int] = []
    
    func updateScoreHeight(myScore:Int, theirScore:Int) {
        let maxScore :Float = 6
        
        var myNormalised = Float(myScore) / maxScore
        var theirNormalised = Float(theirScore) / maxScore
        
        func lerp (val:Float, min:Int, max:Int) -> CGFloat {
            return CGFloat(Float(min) + (Float(max) - Float(min))*val)
        }
        
        myScoreHeight.constant = lerp(myNormalised, minScoreHeight, maxScoreHeight)
        theirScoreHeight.constant = lerp(theirNormalised, minScoreHeight, maxScoreHeight)
        
    }

    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var questionsRemainingLabel: UILabel!
    
    @IBOutlet weak var timeRemainingProgressView: UIProgressView!

    @IBOutlet weak var voteSlider: UISlider?
    @IBOutlet weak var questionLabel: UILabel?
    
    @IBOutlet weak var yourScoreLabel: UILabel?
    @IBOutlet weak var theirScoreLabel: UILabel?
    
    @IBOutlet weak var feedbackLabel: UILabel!

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
        
        self.feedbackLabel.alpha = 0.0
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
        
        
    }
    
    func rotateClock()
    {
        self.spinningView.setProgress(0.0, animated:false)
        self.spinningView.animationDuration = 6
        self.spinningView.startAngle = Float(M_PI_2)
        self.spinningView.tintColor = UIColor.grayColor()
        self.spinningView.setProgress(1.0, animated:true)
    }
    
    func showQuestion() {
        // Get a topic
        
        let person = QuestionDatabase.sharedDatabase.allPeople[heroID]
        
        let policyID = possibleQuestions[Int(arc4random_uniform(UInt32(possibleQuestions.count)))]
        
        if let policy = person?.policies[policyID] {
            self.questionLabel?.text = policy.name
            
            self.questionID = policyID
            
            self.abstainButton.selected = false
            
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
            
            rotateClock()
            
            // firing up the 6 second ticking audio
            //AudioJigger.sharedJigger.playEffect(.Ticking)
        } else {
            // whoa we have no policy? try again
            showQuestion()
        }
        
        
    }
    
    func timeRanOut(sender:AnyObject)
    {

        let correctAnswer = QuestionDatabase.sharedDatabase.correctAnswerForPerson(heroID, policyID: self.questionID!)
        
        var feedbackAnswer : String
        
        switch correctAnswer {
        case .Abstain:
            feedbackAnswer = "They abstained!"
        case .AgreeStrong:
            feedbackAnswer = "They strongly agree!"
        case .Agree:
            feedbackAnswer = "They agree!"
        case .Neutral:
            feedbackAnswer = "They've voted for and against!"
        case .Disagree:
            feedbackAnswer = "They disagree!"
        case .DisagreeStrong:
            feedbackAnswer = "They strongly disagree!"
        }
        
        if correctAnswer == answer {
            AudioJigger.sharedJigger.playEffect(Effects.HereHere)
            feedbackLabel.text = "Correct!"
        } else {
            AudioJigger.sharedJigger.playEffect(Effects.Booing)
            
            feedbackLabel.text = "Incorrect!\n\(feedbackAnswer)"
        }
        
        feedbackLabel.alpha = 0
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.feedbackLabel.alpha = 1.0
        }) { (complete) -> Void in
           UIView.animateWithDuration(0.25, delay: 1.0, options: UIViewAnimationOptions.allZeros, animations: { () -> Void in
            self.feedbackLabel.alpha = 0.0
           }, completion: nil)
        }
        
        Network.sharedNetwork.submitAnswer(self.questionID!, answer: answer)
        
        self.questionsRemaining -= 1
        
        if (self.questionsRemaining > 0) {
            showQuestion()
        } else {
            // Wait for the server to tell us to go to the game over screen
            
            timer?.invalidate()
            timer = nil
        }
        
        
    }
    
    @IBAction func voteSliderValueChange(sender: AnyObject) {
        answer = Answer.fromFloat(self.voteSlider?.value ?? 0.0)
        
        self.abstainButton.selected = false
    }
    
    @IBAction func abstainVote(sender: AnyObject) {
        self.abstainButton.selected = true
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
        
        updateScoreHeight(message.yourScore, theirScore: message.opponentScore)
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "GameOverSegue"
        {
            timer?.invalidate()
            timer = nil
            if let theDestination = segue.destinationViewController as? GameOverLobbyViewController
            {
                theDestination.youWon = gameOverMessage?.youWon ?? false
            }
        }
    }

}
