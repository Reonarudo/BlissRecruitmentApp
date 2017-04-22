//
//  DetailViewController.swift
//  BlissRecruitmentApp
//
//  Created by Leonardo Marques on 20.04.17.
//  Copyright © 2017 Leonardo Marques. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailQuestionLabel: UILabel!
    @IBOutlet weak var detailQuestionImage: UIImageView!
    @IBOutlet weak var detailQuestionPublicationLabel: UILabel!
    @IBOutlet weak var votingView: UIView!

    func configureView() {
        // Update the user interface for the detail item.
        if let title = detailQuestion?.question {
            if let label = detailQuestionLabel {
                label.text = title
            }
        }
        
        if let date = detailQuestion?.publishDate {
            if let label = detailQuestionPublicationLabel {
                label.text = "Published on: \(date)"
            }
        }
        
        if let imageURL = detailQuestion?.imageURL {
            if let image = detailQuestionImage {
                image.imageFromServerURL(urlString: imageURL)
            }
        }
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailQuestion: Question? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

