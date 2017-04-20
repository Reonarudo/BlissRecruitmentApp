//
//  BRALoadingViewController.swift
//  BlissRecruitmentApp
//
//  Created by Leonardo Marques on 20.04.17.
//  Copyright © 2017 Leonardo Marques. All rights reserved.
//

import UIKit
import KRProgressHUD

class BRALoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Start request right before view is displayed
        checkServerHealth()
    }
    
    func checkServerHealth() {
        KRProgressHUD.show()
        BRAPI.sharedInstance.getHealth(success: { result in
            //Go to question list
            KRProgressHUD.dismiss()
            self.navigationController?.popToRootViewController(animated: true)
            //self.navigationController?.dismiss(animated: true, completion: nil)
        }) { error in
            KRProgressHUD.dismiss()
            //Show alert
            let alert = UIAlertController(title: "Alert".localized, message: "Unhealty server".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry".localized, style: .default, handler: { alert in
                print("Going to retry")
                self.checkServerHealth()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
