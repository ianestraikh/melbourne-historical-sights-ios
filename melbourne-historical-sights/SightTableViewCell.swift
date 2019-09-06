//
//  SightTableViewCell.swift
//  melbourne-historical-sights
//
//  Created by Ian Estraikh on 16/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit

class SightTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
