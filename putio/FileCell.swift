//
//  FileCell.swift
//  putio
//
//  Created by Javi Manzano on 31/10/2015.
//  Copyright © 2015 Javi Manzano. All rights reserved.
//

import Foundation
import UIKit

class FileCell: UITableViewCell {
    
    @IBOutlet weak var fileName: UILabel!
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}