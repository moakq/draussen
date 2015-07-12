//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Santi on 6/30/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Bond
import Parse

class PostTableViewCell: UITableViewCell {
    
    var likeBond: Bond<[PFUser]?>!

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likesIconImageView: UIImageView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    
    
    
    @IBAction func moreButtonTapped (sender: AnyObject) {
    
    }
    
    @IBAction func likeButtonTapped (sender: AnyObject) {
        post?.toggleLikePost(PFUser.currentUser()!)
    }
    
    var post:Post? {
        didSet {
            if let post = post {
                // bind the image of the post to the 'postImage' view
                post.image ->> postImageView
                
                // bind the likeBond that we defined earlier, to update like label and button when likes change
                post.likes ->> likeBond
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // 1
        likeBond = Bond<[PFUser]?>() { [unowned self] likeList in
            // 2
            if let likeList = likeList {
                // 3
                self.likesLabel.text = self.stringFromUserList(likeList)
                // 4
                self.likeButton.selected = contains(likeList, PFUser.currentUser()!)
                // 5
                self.likesIconImageView.hidden = (likeList.count == 0)
            } else {
                // 6
                // if there is no list of users that like this post, reset everything
                self.likesLabel.text = ""
                self.likeButton.selected = false
                self.likesIconImageView.hidden = true
            }
        }
    }
    
    func stringFromUserList(userList: [PFUser]) -> String {
        // 1
        let usernameList = userList.map { user in user.username! }
        // 2
        let commaSeparatedUserList = ", ".join(usernameList)
        
        return commaSeparatedUserList
    }
    
}
