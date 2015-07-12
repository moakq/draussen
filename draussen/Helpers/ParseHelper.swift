//
//  ParseHelper.swift
//  Makestagram
//
//  Created by Santi on 6/30/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse

// 1
class ParseHelper {
    
    
    static let ParseFollowClass = "Follow"
    static let ParseFollowFromUser = "fromUser"
    static let ParseFollowToUser = "toUser"
    
    static let ParseLikeClass = "Like"
    static let ParseLikeToPost = "toPost"
    static let ParseLikeFromUser = "fromUser"
    
    static let ParsePostUser = "user"
    static let ParsePostCreatedAt = "createdAt"
    
    static let ParseFlaggedContentClass = "FlaggedContent"
    static let ParseFlaggedContentFromUser = "fromUser"
    static let ParseFlaggedContentToPost = "toPost"
    static let ParseUserUsername = "username"
    
    
    
    // 2
    static func timelineRequestforCurrentUser(range: Range<Int>, completionBlock: PFArrayResultBlock) {
        let followingQuery = PFQuery(className: ParseFollowClass)
        followingQuery.whereKey(ParseLikeFromUser, equalTo:PFUser.currentUser()!)
        
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
        
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
        
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        query.includeKey(ParsePostUser)
        query.orderByDescending(ParsePostCreatedAt)
        
        // 2
        query.skip = range.startIndex
        // 3
        query.limit = range.endIndex - range.startIndex
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    // function to perfom a like to a post from a user in the background

    static func likePost (user: PFUser, post: Post) {
        let likeObject = PFObject(className: ParseLikeClass) //creating an instance of a like (parse class)
        
        //defining the user that tab the like and the Post they liked
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        
        //saving that object to Parse in the background
        likeObject.saveInBackgroundWithBlock(nil)
    }
    
    
    // function to delete a like to a post from a user in the background
    
    static func unlikePost (user: PFUser, post: Post) {
        
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeFromUser, equalTo: user)
        query.whereKey(ParseLikeToPost, equalTo: post)
        query.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]?, error: NSError?) -> Void in
            if let result = results as? [PFObject] {
                for likes in result {
                    likes.deleteInBackgroundWithBlock(nil)
                }
            }
            
        }
    }
    
    
    // function to retrieve all the likes for a given post
    
    static func likesForPost (post: Post, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeToPost, equalTo: post)
        query.includeKey(ParseLikeFromUser)
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
    }
    
    
    
    /**  Fetches all users that the provided user is following.
    :param: user The user whose followees you want to retrieve  :param: completionBlock The completion block that is called when the query completes*/static func getFollowingUsersForUser(user: PFUser, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: ParseFollowClass)
        
        query.whereKey(ParseFollowFromUser, equalTo:user)
        query.findObjectsInBackgroundWithBlock(completionBlock)}
    /**  Establishes a follow relationship between two users.
    :param: user    The user that is following  :param: toUser  The user that is being followed*/static func addFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let followObject = PFObject(className: ParseFollowClass)
        followObject.setObject(user, forKey: ParseFollowFromUser)
        followObject.setObject(toUser, forKey: ParseFollowToUser)
        
        followObject.saveInBackgroundWithBlock(nil)}
    /**  Deletes a follow relationship between two users.
    :param: user    The user that is following  :param: toUser  The user that is being followed*/static func removeFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let query = PFQuery(className: ParseFollowClass)
        query.whereKey(ParseFollowFromUser, equalTo:user)
        query.whereKey(ParseFollowToUser, equalTo: toUser)
        
        query.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]?, error: NSError?) -> Void in
            
            let results = results as? [PFObject] ?? []
            
            for follow in results {
                follow.deleteInBackgroundWithBlock(nil)
            }
        }}
    // MARK: Users
    /**  Fetch all users, except the one that's currently signed in.  Limits the amount of users returned to 20.
    :param: completionBlock The completion block that is called when the query completes
    :returns: The generated PFQuery*/static func allUsers(completionBlock: PFArrayResultBlock) -> PFQuery {
        let query = PFUser.query()!
        // exclude the current user
        query.whereKey(ParseHelper.ParseUserUsername,
            notEqualTo: PFUser.currentUser()!.username!)
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query}
    /**Fetch users whose usernames match the provided search term.
    :param: searchText The text that should be used to search for users:param: completionBlock The completion block that is called when the query completes
    :returns: The generated PFQuery*/static func searchUsers(searchText: String, completionBlock: PFArrayResultBlock)
        -> PFQuery {
            /*    NOTE: We are using a Regex to allow for a case insensitive compare of usernames.    Regex can be slow on large datasets. For large amount of data it's better to store    lowercased username in a separate column and perform a regular string compare.  */
            let query = PFUser.query()!.whereKey(ParseHelper.ParseUserUsername,
                matchesRegex: searchText, modifiers: "i")
            
            query.whereKey(ParseHelper.ParseUserUsername,
                notEqualTo: PFUser.currentUser()!.username!)
            
            query.orderByAscending(ParseHelper.ParseUserUsername)
            query.limit = 20
            
            query.findObjectsInBackgroundWithBlock(completionBlock)
            
            return query}

    
    
}



extension PFObject : Equatable {
    
}

public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
    return lhs.objectId == rhs.objectId
}