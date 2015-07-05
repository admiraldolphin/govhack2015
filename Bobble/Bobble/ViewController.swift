//
//  ViewController.swift
//  Bobble
//
//  Created by Tim Nugent on 5/07/2015.
//  Copyright (c) 2015 Tim Nugent. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var faceImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.faceImageView.transform = CGAffineTransformMakeRotation(-0.785)
        
        self.bobble(0.785)
    }
    
    func bobble(angle:Float)
    {
        UIView.animateWithDuration(0.8, delay: 0.0, options: UIViewAnimationOptions.Repeat | UIViewAnimationOptions.Autoreverse, animations: { () -> Void in
            self.faceImageView.transform = CGAffineTransformMakeRotation(0.785)
            }) { (completed) -> Void in
                println("bobble")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

