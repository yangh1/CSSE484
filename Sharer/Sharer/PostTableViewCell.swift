//
//  PostTableViewCell.swift
//  Sharer
//
//  Created by 杨桦 on 8/3/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViewForCell(post: Post) {
        self.usernameLabel.text = post.username
        self.postTextView.text = post.postText
    }
    
}
