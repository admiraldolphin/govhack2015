//
//  QuestionDatabase.swift
//  QuestionTime
//
//  Created by Jon Manning on 4/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import Foundation
import UIKit

let DataFolder = "data"
let PeopleManifest = "people.json"
let PortfoliosManifest = "portfolios.json"

class Policy {
    var id : Int = 0
    var name : String = ""
    var description : String = ""
    
}

class Portfolio {
    var questionIDs : [Int] = []
}

class Person {
    
    var id : Int = 0
    var name : String = ""
    lazy var photo : UIImage? = {
        
        let path = "data/photos/\(self.id).jpg"
        
        if let baseURL = NSBundle.mainBundle().resourceURL {
            let photoURL = baseURL.URLByAppendingPathComponent(path)
            
            if let loadedData = NSData(contentsOfURL: photoURL) {
                return UIImage(data: loadedData)
            }
        }
        
        return nil
        
        
    }()
    
    var policies : [Policy] = []
}

class QuestionDatabase : NSObject {
    static var sharedNetwork = {
        return Network()
    }()
    
    
    
    override init() {
        super.init()
        
    }
    
}