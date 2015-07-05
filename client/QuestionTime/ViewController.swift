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
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"BGTileLoseScreen")!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        QuestionDatabase.sharedDatabase.resetAskedQuestions()
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
        return QuestionDatabase.sharedDatabase.importantPeople.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemberCell", forIndexPath: indexPath) as! MemberCollectionViewCell
        
        let key = QuestionDatabase.sharedDatabase.importantPeople.keys.array.sorted(<)[indexPath.row]
        let person = QuestionDatabase.sharedDatabase.importantPeople[key]
        if let thePerson = person
        {
            cell.memberNameLabel.text = thePerson.name
            cell.portraitImageView.image = UIImage(named: "\(key)")
            
            if thePerson.party == "Australian Labor Party"
            {
                let theColour = UIColor(red: 0.7411764706, green: 0, blue: 0.1490196078, alpha: 1)
                cell.portraitImageView.backgroundColor = theColour
            }
            else if thePerson.party == "Liberal Party"
            {
                let theColour = UIColor(red: 0.03921568627, green: 0.3490196078, blue: 0.6705882353, alpha: 1)
                cell.portraitImageView.backgroundColor = theColour
            }
            else if thePerson.party == "National Party"
            {
                cell.portraitImageView.backgroundColor = UIColor.blueColor()
            }
            else if thePerson.party == "Australian Greens"
            {
                let theColour = UIColor(red: 0.07058823529, green: 0.5294117647, blue: 0.1803921569, alpha: 1)
                cell.portraitImageView.backgroundColor = theColour
            }
            else
            {
                cell.portraitImageView.backgroundColor = UIColor.grayColor()
            }
        }
        
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        AudioJigger.sharedJigger.playEffect(.Selection)
        println("index path:\(indexPath.row)")
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
                        println("index path2: \(indexPath.row)")
                        let key = QuestionDatabase.sharedDatabase.importantPeople.keys.array.sorted(<)[indexPath.row]
                        println("Important: \(key)")
                        destination.honourableMember = key
                    }
                }
            }
        }
    }


}

