//
//  BRAChoiceView.swift
//  BlissRecruitmentApp
//
//  Created by Leonardo Marques on 22.04.17.
//  Copyright © 2017 Leonardo Marques. All rights reserved.
//

import UIKit

class BRAChoiceView: UIView {

    @IBOutlet weak var choiceProgress: UIProgressView!
    @IBOutlet weak var choiceVoteButton: UIButton!
    @IBOutlet weak var voteCountLabel: UILabel!
    


    class func instanceFromNib() -> BRAChoiceView {
        return UINib(nibName: "BRAVoteViewController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! BRAChoiceView
    }
    
}
