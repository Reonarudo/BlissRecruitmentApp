//
//  Question.swift
//  BlissRecruitmentApp
//
//  Created by Leonardo Marques on 22.04.17.
//  Copyright © 2017 Leonardo Marques. All rights reserved.
//

import Foundation

//typealias Choice = (choice:String, votes:Int)

struct Question {
    static let kQuestionDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    
    var id:Int
    var question:String
    var imageURL:String
    var thumbURL:String
    var publishDate:Date
    var choices:[String:Int]
    
    //Parser json->model function
    static func getQuestion(from json:[String:Any?]) -> Question {
        //parse choices
        var choices:[String:Int]=[String:Int]()
        for choice in json["choices"] as! Array<[String:Any?]>{
            choices[choice["choice"] as! String] = Int(choice["votes"] as! NSNumber)
        }
        //parse date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kQuestionDateFormat
        let date:Date = dateFormatter.date(from: json["published_at"] as! String)!
        //Build struct
        return Question(id: Int(json["id"] as! NSNumber),
                        question: json["question"] as! String,
                        imageURL: json["image_url"] as! String,
                        thumbURL: json["thumb_url"] as! String,
                        publishDate: date,
                        choices: choices)
    }
    
    func json()->[String:Any]{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Question.kQuestionDateFormat
        var jsonDict:[String:Any]=["id":id, "question":question, "image_url":imageURL, "thumb_url":thumbURL, "published_at":dateFormatter.string(from: publishDate)]
        //Build choices json array
        var choicesArr:Array<[String:Any]>=Array<[String:Any]>()
        for choice in self.choices{
            var c:[String:Any]=[String:Any]()
            c["choice"]=choice.key
            c["votes"]=choice.value
            choicesArr.append(c)
        }
        jsonDict["choices"]=choicesArr
        
        return jsonDict
    }
}
