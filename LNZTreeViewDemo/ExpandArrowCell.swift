//
//  ExpandArrowCell.swift
//  LNZTreeViewDemo
//
//  Created by anhdn on 10/30/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import UIKit

class ExpandArrowCell: UITableViewCell {

    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var nodeTitleLabel: UILabel!

    var onExpand: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func expandButtonTapped(_ sender: Any) {
        self.onExpand?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        guard var imageFrame = imageView?.frame else { return }
        
        let offset = CGFloat(indentationLevel) * indentationWidth
        imageFrame.origin.x += offset
        imageView?.frame = imageFrame
    }
}
