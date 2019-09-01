//
//  SortTableViewCell.swift
//  melbourne-historical-sights
//
//  Created by Ian Estraikh on 1/9/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit

class SortTableViewCell: UITableViewCell {
    @IBOutlet weak var sortSegmentedConrol: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
