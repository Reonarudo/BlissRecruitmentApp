//
//  Question.swift
//  BlissRecruitmentApp
//
//  Created by Leonardo Marques on 22.04.17.
//  Copyright © 2017 Leonardo Marques. All rights reserved.
//

import Foundation

typealias Choice = (choice:String, votes:Int)

struct Question {
    static let kQuestionDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    
    var id:Int
    var question:String
    var imageURL:String
    var thumbURL:String
    var publishDate:Date
    var choices:[Choice]
    
    //Parser json->model function
    static func getQuestion(from json:[String:Any?]) -> Question {
        //parse choices
        var choices:[Choice]=[Choice]()
        for choice in json["choices"] as! Array<[String:Any?]>{
            choices.append(Choice(choice["choice"] as! String,Int(choice["votes"] as! NSNumber)))
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
}
