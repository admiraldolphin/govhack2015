//
//  ViewController.swift
//  QuestionTime
//
//  Created by Jon Manning on 3/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var network : Network?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        network = Network(host: "localhost", port: 1234)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

