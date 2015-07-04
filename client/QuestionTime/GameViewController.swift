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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    }
    func networkDidUpdateGameProgress(message: ProgressMessage) {
        // ok here is what we care about
        // later on we should show some sort of indication as to how right/wrong they were
        // for now just push a new question onto the stack
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
