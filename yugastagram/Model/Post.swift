//
//  Post.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/11.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase
class Post {
    var caption: String?
    var photoUrl: String?
    var uid: String?
    var id: String?
    var likeCount: Int?
    var likes: Dictionary<String,Any>?
    var isLiked: Bool?
    var ratio :CGFloat?
    var videoUrl: String?
    var timestamp:Int?
}

extension Post {
    static func transformPostPhoto(dict: [String: Any],key: String) -> Post {
        let post = Post()
        post.id = key
        post.caption = dict["caption"] as? String
        post.photoUrl = dict["photoUrl"] as? String
        post.videoUrl = dict["videoUrl"] as? String
        post.uid = dict["uid"] as? String
        post.likeCount = dict["likeCount"] as? Int
        post.likes = dict["likes"] as? Dictionary<String,Any>
        post.ratio = dict["ratio"] as? CGFloat
        post.timestamp = dict["timestamp"] as? Int
        if let currentUserId = Auth.auth().currentUser?.uid{
            if post.likes != nil {
                post.isLiked = post.likes![currentUserId] != nil
        }
    }
    return post
}
    static func transformPostVideo() {
        
    }
}
