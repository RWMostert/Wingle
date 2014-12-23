//
//  ImageSharingTableViewCell.swift
//  Wingle
//
//  Created by Rayno Mostert on 2014/12/10.
//  Copyright (c) 2014 Rayno Mostert. All rights reserved.
//

import UIKit

public class ImageSharingTableViewCell: UITableViewCell {

    @IBOutlet var ratingSegments: UISegmentedControl!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var imageLoadProgressView: UIProgressView!
    @IBOutlet var cellImage: UIImageView!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageLoadProgressView.setProgress(0, animated: true)
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setProgress(progress: Int32){
        imageLoadProgressView.setProgress(Float(progress)/100, animated: true)
        println(Float(progress)/100)
    }

}
