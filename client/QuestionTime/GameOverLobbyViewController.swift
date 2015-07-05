//
//  GameOverLobbyViewController.swift
//  QuestionTime
//
//  Created by Tim Nugent on 4/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import UIKit

class GameOverLobbyViewController: UIViewController {

    var youWon : Bool = false
    
    var portfolios : [Int] = []
    
    @IBOutlet weak var gameOverLobbyLabel: UILabel!
    
    @IBOutlet weak var factoid1Label: UILabel!
    @IBOutlet weak var factoid2Label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AudioJigger.sharedJigger.playBackgroundMusic()
        
    
        if youWon
        {
            self.gameOverLobbyLabel.text = "The honourable member is ejected from the house!"
            AudioJigger.sharedJigger.playEffect(.Victory)
        }
        else
        {
            self.gameOverLobbyLabel.text = "The honourable member has the call!"
            AudioJigger.sharedJigger.playEffect(.Defeat)
        }
    

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func restartGame(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
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
