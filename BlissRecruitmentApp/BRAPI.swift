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
        
        Alamofire.request("\(BRAPI.kHost)/health").validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Success")
                
                sBlock(response.result.value as! [String : Any?])
            case .failure(let error):
                print("Error")
                print(error)
                
                fBlock(error)
            }
        }
        
    }
}
