//
//  LocalizedString.swift
//  BlissRecruitmentApp
//
//  Created by Leonardo Marques on 20.04.17.
//  Copyright © 2017 Leonardo Marques. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
