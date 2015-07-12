//
//  Post.swift
//  Makestagram
//
//  Created by Santi on 6/30/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse
import Bond

class Post : PFObject, PFSubclassing {
    
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    var likes =  Dynamic<[PFUser]?>(nil)
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
    // var image: UIImage? //old declaration
    var image: Dynamic<UIImage?> = Dynamic(nil)
    
    //MARK: PFSubclassing protocol
    
    static func parseClassName() -> String {
        return "Post"
    }
    
    override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }

    ////////////////////////// all the previous code is coming from Parse to subclass
    
    ///// writing my own method
    
    func uploadPost () {
     let imageData = UIImageJPEGRepresentation(image.value, 0.8)
        let imageFile = PFFile(data: imageData)
        imageFile.saveInBackgroundWithBlock(nil)
        
        
        //1 
        photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        
        
        //2
        imageFile.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        
        
        
        user = PFUser.currentUser() // user is part of the Post class, here we assign to the current user on the session at Parse... our post will show the user that is posting the image
        
        self.imageFile = imageFile
        saveInBackgroundWithBlock(nil) // nil because now I don't want to get informed when the upload to parse is completed...
    }
    
    func downloadImage() {
        // if image is not downloaded yet, get it
        // 1
        if (image.value == nil) {
            // 2
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    // 3
                    self.image.value = image
                }
            }
        }
    }
    
    
    
    func fetchLikes() {

        // 1
        if (likes.value != nil) {
            return
        }
        
        // 2
        ParseHelper.likesForPost(self, completionBlock: { (var likes: [AnyObject]?, error: NSError?) -> Void in
            // 3
            likes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
            
            // 4
            self.likes.value = likes?.map { like in
                let like = like as! PFObject
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                return fromUser
            }
        })
    }
    
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return contains(likes, user)
        } else {
            return false
        }
    }
    
    
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            // if image is liked, unlike it now
            // 1
            likes.value = likes.value?.filter { $0 != user }
            ParseHelper.unlikePost(user, post: self)
        } else {
            // if this image is not liked yet, like it now
            // 2
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
    
    
}