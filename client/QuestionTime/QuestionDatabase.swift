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

struct PolicyComparison {
    var id : Int = 0
    var name : String = ""
    var description : String = ""
    var agreement : Float = 0.0
    var abstained : Bool = false
    
}

struct Portfolio {
    var name : String = ""
    var questionIDs : [Int] = []
    var id : Int = 0
}

class Person {
    
    var id : Int = 0
    var name : String = ""
    var party : String = ""
    
    enum Gender : UInt {
        case Female
        case Male
    }
    
    var gender : Gender = .Female
    
    init(id: Int, name:String, gender:Gender) {
        self.id = id
        self.name = name
        self.gender = gender
    }
    
    init(id: Int, name:String, gender:Gender, party:String)
    {
        self.id = id
        self.name = name
        self.gender = gender
        self.party = party
    }
    
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
    
    lazy var policies : [Int:PolicyComparison] = {
        
        let path = "data/people/\(self.id).json"
        
        var policies : [Int:PolicyComparison] = [:]
        
        if let personURL = NSBundle.mainBundle().resourceURL?.URLByAppendingPathComponent(path) {
            
            let personData = JSON(data: NSData(contentsOfURL: personURL)!)
            
            for policyData in personData["policy_comparisons"].arrayValue {
                
                let comparison = PolicyComparison(id: policyData["policy"]["id"].intValue,
                    name: policyData["policy"]["name"].stringValue,
                    description: policyData["policy"]["description"].stringValue,
                    agreement: policyData["agreement"].floatValue,
                    abstained: policyData["voted"].boolValue == false)
                
                policies[comparison.id] = comparison
                
            }
            
        }
        
        return policies
        
    }()
    
}

class QuestionDatabase : NSObject {
    static var sharedDatabase = {
        return QuestionDatabase()
    }()
    
    var askedQuestions : [Int] = []
    
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
    
    lazy var allPeople : [Int:Person] = {
        var people : [Int:Person] = [:]
        let path = "data/people.json"
        
        if let peopleURL = NSBundle.mainBundle().resourceURL?.URLByAppendingPathComponent(path) {
            let peopleData = JSON(data: NSData(contentsOfURL: peopleURL)!)
            
            for personData in peopleData.arrayValue {
                
                let nameData = personData["latest_member"]["name"]
                let name = nameData["first"].stringValue + " " + nameData["last"].stringValue
                let party = personData["latest_member"]["party"].stringValue
                
                var gender : Person.Gender
                switch personData["latest_member"]["gender"].stringValue {
                case "Female":
                    gender = .Female
                case "Male":
                    fallthrough
                default:
                    gender = .Male
                
                    
                }
                
                let person = Person(
                    id: personData["id"].intValue,
                    name: name,
                    gender: gender,
                    party: party)
                
                people[person.id] = person
            }
        }
        
        return people
        
    }()
    
    lazy var importantPeople : [Int:Person] = {
        let peepsID = [10727,10513,10580,10798,10306,10080,10047,10001]
        
        var allPeeps = self.allPeople
        var importants : [Int:Person] = [:]
        
        for person in allPeeps
        {
            let individual = person.1
            if contains(peepsID, individual.id)
            {
                importants[individual.id] = individual
            }
        }
        
        return importants
    }()
    
    func correctAnswerForPerson(personID: Int, policyID:Int) -> Answer {
        if let policy = allPeople[personID]?.policies[policyID] {
                
                if policy.abstained {
                    return Answer.Abstain
                }
                
                switch policy.agreement {
                case 0...20:
                    return Answer.DisagreeStrong
                case 21...40:
                    return Answer.Disagree
                case 41...60:
                    return Answer.Neutral
                case 61...80:
                    return Answer.Agree
                case 81...100:
                    return Answer.AgreeStrong
                default:
                    return Answer.Abstain

                }
           
        }
        
        return Answer.Abstain
    }
    
    func resetAskedQuestions()
    {
        self.askedQuestions = []
    }
    
    func interestFactAboutQuestion(questionID:Int) -> String?
    {
        var theFact : String?
        // need to go through the policyfacts db
        let policyPath = "data/policyfacts.json"
        let factsPath = "data/facts.json"
        // grab the element at index questionID
        if let policyURL = NSBundle.mainBundle().resourceURL?.URLByAppendingPathComponent(policyPath)
        {
            let policyData = JSON(data: NSData(contentsOfURL: policyURL)!)
            for policyFacts in policyData.arrayValue
            {
                let id = policyFacts["id"].intValue
                if id == questionID
                {
                    // this is the question we want
                    let factIDs = policyFacts["facts"].arrayValue
                    
                    let random = Int(arc4random_uniform(UInt32(factIDs.count)))
                    let factID = factIDs[random].intValue
                    
                    if let factURL = NSBundle.mainBundle().resourceURL?.URLByAppendingPathComponent(factsPath)
                    {
                        let factData = JSON(data: NSData(contentsOfURL: factURL)!)
                        for facts in factData.arrayValue
                        {
                            let theID = facts["id"].intValue
                            if factID == theID
                            {
                                // this is the fact we are after
                                theFact = facts["text"].stringValue
                            }
                        }
                    }
                }
            }
        }
        return theFact
    }
    
    
    override init() {
        super.init()
        
    }
    
}