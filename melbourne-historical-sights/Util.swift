//
//  Util.swift
//  melbourne-historical-sights
//
//  Created by Ian Estraikh on 19/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//
import UIKit

func loadImageData(filename: String) -> UIImage? {
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    
    let url = NSURL(fileURLWithPath: path)
    var image: UIImage?
    if let pathComponent = url.appendingPathComponent(filename) {
        let filePath = pathComponent.path
        let fileManager = FileManager.default
        let fileData = fileManager.contents(atPath: filePath)
        image = UIImage(data: fileData!)
    }
    
    return image
}
