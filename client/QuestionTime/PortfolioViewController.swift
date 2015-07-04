//
//  PortfolioViewController.swift
//  QuestionTime
//
//  Created by Tim Nugent on 4/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import UIKit

class PortfolioViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    let portfolioList : [String] = ["Health","Economy","Administrative","Science","Education","Foreign","Tech","Social"]
    
    var honourableMember : String?

    @IBOutlet weak var portfolioCollectionVew: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return portfolioList.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PortfolioCell", forIndexPath: indexPath) as! PortfolioCollectionViewCell
        
        cell.portfolioNameLabel.text = portfolioList[indexPath.row]
        
        return cell
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "PortfolioSelectionSegue")
        {
            // need to tell the server about it
            // or is it better to wait and do it in the lobby?
            // eh let's do it in the lobby
            if let destination = segue.destinationViewController as? PreGameLobbyViewController
            {
                if let cell = sender as? PortfolioCollectionViewCell
                {
                    if let indexPath = portfolioCollectionVew.indexPathForCell(cell)
                    {
                        destination.honourableMember = self.honourableMember
                        destination.portfolio = self.portfolioList[indexPath.row]
                    }
                }
            }
        }
    }

}
