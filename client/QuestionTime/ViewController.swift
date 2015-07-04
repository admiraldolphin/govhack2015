//
//  ViewController.swift
//  QuestionTime
//
//  Created by Jon Manning on 3/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, NetworkDelegate {
    
    var network : Network?
    
    @IBOutlet weak var memberListView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Network.sharedNetwork.delegate = self
        
        Network.sharedNetwork.connect()
        
        // starting up the background audio
        AudioJigger.sharedJigger.playBackgroundMusic()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"BGTile")!)
    }
    
    func networkConnected() {
        println("Network connected!")
        
    }
    
    func networkDisconnected(error: NSError?) {
        println("Network disconnected!")
    }
    
    func networkDidStartGame(message: GameStartMessage) {
        
    }
    
    func networkDidEndGame(message: GameOverMessage) {
        
    }
    
    func networkDidUpdateGameProgress(message: ProgressMessage) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CollectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return QuestionDatabase.sharedDatabase.allPeople.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemberCell", forIndexPath: indexPath) as! MemberCollectionViewCell
        
        let key = QuestionDatabase.sharedDatabase.allPeople.keys.array.sorted(<)[indexPath.row]
        let person = QuestionDatabase.sharedDatabase.allPeople[key]
        if let thePerson = person
        {
            cell.memberNameLabel.text = thePerson.name
        }
        
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        AudioJigger.sharedJigger.playEffect(Effects.Selection)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "MemberSelectedSegue")
        {
            // we are transitioning to the choose portfolio view
            // send over the selected mp
            if let destination = segue.destinationViewController as? PortfolioViewController
            {
                if let cell = sender as? MemberCollectionViewCell
                {
                    if let indexPath = memberListView.indexPathForCell(cell)
                    {
                        let key = QuestionDatabase.sharedDatabase.allPeople.keys.array.sorted(<)[indexPath.row]
                        destination.honourableMember = key
                    }
                }
            }
        }
    }


}

