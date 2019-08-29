//
//  LocationAnnotationView.swift
//  melbourne-historical-sights
//
//  Created by Ian Estraikh on 29/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit

class LocationAnnotationView: UIView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
}

// https://stackoverflow.com/questions/24857986/load-a-uiview-from-nib-in-swift
extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
