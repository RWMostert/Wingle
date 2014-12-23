//
//  PFImageTableViewCell.swift
//  Wingle
//
//  Created by Rayno Mostert on 2014/12/13.
//  Copyright (c) 2014 Rayno Mostert. All rights reserved.
//

import UIKit

class PFImageTableViewCell: PFTableViewCell {

    @IBOutlet var DateLabel: UILabel!
    @IBOutlet var AuthorLabel: UILabel!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var feedImageView: PFImageView!
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
