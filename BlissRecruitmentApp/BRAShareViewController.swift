//
//  BRAShareViewController.swift
//  BlissRecruitmentApp
//
//  Created by Leonardo Marques on 23.04.17.
//  Copyright © 2017 Leonardo Marques. All rights reserved.
//

import UIKit
import KRProgressHUD

class BRAShareViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var shareButton: UIButton!
    
    var shareTitle:String?
    var urlToShare:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        emailTextField.delegate = self
        shareButton.isEnabled=false
        
        if let sTitle=shareTitle {
            titleLabel.text=sTitle
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK - Textfiled
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let email=emailTextField.text, email.characters.count>5{
            self.resignFirstResponder()
            self.view.endEditing(true)
            shareButton.isEnabled=true
        } else{
            shareButton.isEnabled=false
        }
        return true
    }
    
    
    // MARK - Share
    
    @IBAction func shareAction(_ sender: Any) {
        //check mandatory fields
        guard let url=urlToShare else{
            KRProgressHUD.showError(message: "Error")
            return
        }
        guard let email=emailTextField.text, email.characters.count>5 else{
            KRProgressHUD.showError(message: "Error")
            return
        }
        
        KRProgressHUD.show()
        BRAPI.sharedInstance.share(url: url, with: email, success: { _ in
            KRProgressHUD.showSuccess()
            self.navigationController?.dismiss(animated: true, completion: nil)
        }) { error in
            KRProgressHUD.showError(message: "Error")
        }
        
    }
    
}
