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

struct Portfolio {
    var name : String = ""
    var questionIDs : [Int] = []
    var id : Int = 0
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
    
    lazy var allPortfolios : [Portfolio] = {
        
        var portfolios : [Portfolio] = []
        let path = "data/portfolios.json"
        
        if let portfoliosURL = NSBundle.mainBundle().resourceURL?.URLByAppendingPathComponent(path) {
            
            let portfolioData = JSON(data: NSData(contentsOfURL: portfoliosURL)!)
            
            for data in portfolioData["portfolios"].arrayValue {
                portfolios.append(Portfolio(name: data["name"].stringValue,
                    questionIDs: data["policies"].arrayObject as! [Int],
                    id: data["id"].intValue))
            }
        }
        
        return portfolios
        
    }()
    
    
    
    override init() {
        super.init()
        
    }
    
}