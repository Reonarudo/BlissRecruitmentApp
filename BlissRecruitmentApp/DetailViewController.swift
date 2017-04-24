//
//  DetailViewController.swift
//  BlissRecruitmentApp
//
//  Created by Leonardo Marques on 20.04.17.
//  Copyright © 2017 Leonardo Marques. All rights reserved.
//

import UIKit
import KRProgressHUD

class DetailViewController: UIViewController {
    let kChoiceHeight:CGFloat = 50

    @IBOutlet weak var detailQuestionLabel: UILabel!
    @IBOutlet weak var detailQuestionImage: UIImageView!
    @IBOutlet weak var detailQuestionPublicationLabel: UILabel!
    @IBOutlet weak var votingView: UIView!
    
    var hasVoted:Bool = false
    
    var detailQuestion: Question? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let title = detailQuestion?.question {
            if let label = detailQuestionLabel {
                label.text = title
            }
        }
        
        if let date = detailQuestion?.publishDate {
            if let label = detailQuestionPublicationLabel {
                label.text = "Published on: \(date)".localized
            }
        }
        
        if let imageURL = detailQuestion?.imageURL {
            if let image = detailQuestionImage {
                image.imageFromServerURL(urlString: imageURL)
            }
        }
        
        guard votingView != nil else {
            return
        }
        
        let votingViewSize=CGFloat((detailQuestion?.choices)!.count)*kChoiceHeight
        votingView.frame=CGRect(origin: votingView.frame.origin,
                                size: CGSize(
                                    width: votingView.frame.size.width,
                                    height: votingViewSize))
        
        let choiceViewSize=CGSize(width: votingView.frame.width, height: kChoiceHeight)
        
        //remove old vote stats
        if votingView.subviews.count>0{
            votingView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        //Build and fill progress bars
        var i=0
        let maxVote=(detailQuestion?.choices)!.reduce(0) { $0 < $1.value ? $1.value : $0}
        for choice in (detailQuestion?.choices)!{
            let choiceView=BRAChoiceView.instanceFromNib()
            
            choiceView.frame=CGRect(origin: CGPoint(x: 0, y: CGFloat(i)*kChoiceHeight), size: choiceViewSize)
            
            
            
            choiceView.voteCountLabel?.text="\(choice.value)"
            choiceView.choiceProgress?.progress = Float(choice.value)/Float(maxVote)
            choiceView.choiceVoteButton?.setTitle(choice.key, for: .normal)
            choiceView.choiceVoteButton?.addTarget(self, action: #selector(choiceVote(_:)), for: .touchUpInside)
            
            
            i+=1
            
                votingView.addSubview(choiceView)
            
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

    
    // MARK - Voting
    func choiceVote(_ sender: UIButton){
        
        //Send vote to server
        guard var question=detailQuestion else{
            return
        }
        guard let key=sender.titleLabel?.text else{
            return
        }
        

        if let votes=question.choices[key] {
            question.choices[key] = votes+1
        }
        KRProgressHUD.show()
        BRAPI.sharedInstance.update(question, success: { result in
            self.detailQuestion=Question.getQuestion(from: result)
            self.hasVoted=true
            self.configureView()
            KRProgressHUD.showSuccess()
        }) { error in
            KRProgressHUD.showError(message: error.localizedDescription)
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "shareQuestionSegue" {
            //Build sharable URL
            guard let question=detailQuestion else{
                return
            }
            let searchURLToShare = "blissrecruitment://questions?question_id=\(question.id)"
            
            let controller:BRAShareViewController = segue.destination as! BRAShareViewController
            controller.shareTitle = "Share Question".localized
            controller.urlToShare = searchURLToShare
        }
    }
    
    
}

