
//
//  UIIaageView.swift
//  BlissRecruitmentApp
//
//  Created by Leonardo Marques on 22.04.17.
//  Copyright © 2017 Leonardo Marques. All rights reserved.
//

import Foundation
import UIKit

//Async image loading
extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            guard error == nil else{
                print("\(error!)")
                return
            }
            DispatchQueue.global(qos: .background).async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }
}
