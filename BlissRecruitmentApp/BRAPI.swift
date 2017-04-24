//
//  BRAPI.swift
//  BlissRecruitmentApp
//
//  Created by Leonardo Marques on 20.04.17.
//  Copyright © 2017 Leonardo Marques. All rights reserved.
//

import Foundation
import Alamofire

//Singleton
class BRAPI{
    //Requrements host
    static let kHost:String="https://private-bbbe9-blissrecruitmentapi.apiary-mock.com"
    //Apiary host
    //static let kHost:String="https://private-anon-ff232ab03c-blissrecruitmentapi.apiary-mock.com"

    
    static let sharedInstance:BRAPI=BRAPI()
    private init(){}
    
    func getHealth(success sBlock:@escaping (_ responseObject: [String:Any?])->(),
                   failure fBlock: @escaping (_ error: Error)->()) {
        //Request
        Alamofire.request("\(BRAPI.kHost)/health").validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Success - Healthy")
                
                sBlock(response.result.value as! [String : Any?])
            case .failure(let error):
                print("Error")
                print(error)
                
                fBlock(error)
            }
        }
        
    }
    
    func getAllQuestions(_ limit:Int, _ offset:Int,_ filter:String?=nil,
        success sBlock:@escaping (_ responseObject: [String:Any?])->(),
        failure fBlock: @escaping (_ error: Error)->()
        ) {
        //Optional parameter
        let filterParameter:String = (filter != nil ? "&\(filter!)" : "").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        //Request
        Alamofire.request("\(BRAPI.kHost)/questions?\(limit)&\(offset)\(filterParameter)").validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Success - Received questions")
                sBlock(["questions":response.result.value])
            case .failure(let error):
                print("Error")
                print(error)
                
                fBlock(error)
            }
        }
    }
    
    func get(question number:Int,
                     success sBlock:@escaping (_ responseObject: [String:Any?])->(),
                     failure fBlock: @escaping (_ error: Error)->()
        ){
        
        Alamofire.request("\(BRAPI.kHost)/questions/\(number)").validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Success - Received question")
                sBlock(response.result.value as! [String:Any?])
            case .failure(let error):
                print("Error")
                print(error)
                
                fBlock(error)
            }
        }
        
    }
    
    func update(_ question:Question,
                        success sBlock:@escaping (_ responseObject: [String:Any?])->(),
                        failure fBlock: @escaping (_ error: Error)->()
        ) {
        
        let body:Parameters = question.json()
        Alamofire.request("\(BRAPI.kHost)/questions/\(question.id)", method:.put, parameters: body, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Success - Updated question")
                sBlock(response.result.value as! [String:Any?])
            case .failure(let error):
                print("Error")
                print(error)
                
                fBlock(error)
            }
        }
    }
    
    
}
