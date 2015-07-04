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
    
    let tempMPList : [String] = ["Tone","Joe","Bill","Tanya","Julia","Anna","Wilki","Cathy"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Network.sharedNetwork.delegate = self
        Network.sharedNetwork.connect("localhost")
        
        
    }
    
    func networkConnected() {
        println("Network connected!")
        
        Network.sharedNetwork.selectPlayerData(1, questionCategory: 1)
    }
    
    func networkDisconnected(error: NSError?) {
        println("Network disconnected!")
    }
    
    func networkStateChanged(oldState: GameState, newState: GameState, context: [String : AnyObject]) {
        println("State changed from \(oldState) to \(newState)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CollectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tempMPList.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemberCell", forIndexPath: indexPath) as! MemberCollectionViewCell
        
        cell.memberNameLabel.text = tempMPList[indexPath.row]
        
        return cell
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
                        destination.honourableMember = tempMPList[indexPath.row]
                    }
                }
            }
        }
    }


}

