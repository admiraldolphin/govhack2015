//
//  GameOverLobbyViewController.swift
//  QuestionTime
//
//  Created by Tim Nugent on 4/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import UIKit

class GameOverLobbyViewController: UIViewController {

    var youWon : Bool?
    
    @IBOutlet weak var gameOverLobbyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let iWon = self.youWon
        {
            if iWon
            {
                self.gameOverLobbyLabel.text = "Congrats!"
            }
            else
            {
                self.gameOverLobbyLabel.text = "Suck it!"
            }
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
