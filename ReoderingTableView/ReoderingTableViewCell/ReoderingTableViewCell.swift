//
//  ReoderingTableViewCell.swift
//  ReoderingTableView
//
//  Created by goat_herd on 4/15/19.
//  Copyright © 2019 goat_herd. All rights reserved.
//

import UIKit

class ReoderingTableViewCell: UITableViewCell {
    @IBOutlet private weak var idLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setTitle(_ title: String) {
        idLabel.text = title
    }
    
}
