//
//  GameViewController.swift
//  QuestionTime
//
//  Created by Tim Nugent on 4/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import UIKit

class GameViewController: UIViewController,NetworkDelegate {
    var questionID : Int?

    @IBOutlet weak var voteSlider: UISlider!
    @IBOutlet weak var questionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // need to set the question to what matches the questionID
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSTimer.scheduledTimerWithTimeInterval(6, target: self, selector: "timeRanOut:", userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func timeRanOut(sender:AnyObject)
    {
        // ran out of time, push onto the next question
        self.performSegueWithIdentifier("NewQuestionSegue", sender: self)
    }
    
    @IBAction func voteSliderValueChange(sender: AnyObject) {
        let voteSliderValue : Int = lroundf(self.voteSlider.value)
        
        // terrible hack to force the slider to move in discrete steps
        self.voteSlider.setValue(Float(voteSliderValue), animated: true)
        
        // now tell the server about it
        let answer = Answer(rawValue: voteSliderValue)
        if let theAnswer = answer
        {
            if let theQuestionID = self.questionID
            {
                Network.sharedNetwork.submitAnswer(theQuestionID, answer: theAnswer)
            }
        }
    }
    @IBAction func abstainVote(sender: AnyObject) {
        // tell the server about it
        if let theQuestionID = self.questionID
        {
            Network.sharedNetwork.submitAnswer(theQuestionID, answer: Answer.Abstain)
        }
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
        self.performSegueWithIdentifier("GameOverSegue", sender: message.youWon)
    }
    func networkDidUpdateGameProgress(message: ProgressMessage) {
        // ok here is what we care about
        // later on we should show some sort of indication as to how right/wrong they were
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "NewQuestionSegue"
        {
            // basically I need to give the destination a question id
            // set the network delegate to be the destination
        }
        else if segue.identifier == "GameOverSegue"
        {
            let youWon : Bool = sender as! Bool
            if let theDestination = segue.destinationViewController as? GameOverLobbyViewController
            {
                theDestination.youWon = youWon
            }
        }
    }

}
