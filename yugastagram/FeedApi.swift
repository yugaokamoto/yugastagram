//
//  FeedApi.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/18.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase

class FeedApi{
    var REF_FEED = Database.database().reference().child("feed")
    
    func observeFeed(withId id:String,completion: @escaping (Post) -> Void){
        REF_FEED.child(id).queryOrdered(byChild: "timestamp").observe(.childAdded, with: {
            snapshot in
            let key = snapshot.key
            Api.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
    
    func observeFeedRemove(withId id:String,completion: @escaping (Post) -> Void){
        REF_FEED.child(id).observe(.childRemoved, with: {
            snapshot in
            let key = snapshot.key
            Api.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
    
    
}
