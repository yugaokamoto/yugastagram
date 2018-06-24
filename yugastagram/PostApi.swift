//
//  PostApi.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/15.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class PostApi{
    var REF_POSTS = Database.database().reference().child("posts")
    
    func observePosts(completion: @escaping (Post) -> Void){
        REF_POSTS.observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let newPost = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(newPost)
            }
        }
    }
    
    func observePost(withId id:String, completion: @escaping (Post) -> Void){
        REF_POSTS.child(id).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(post)
            }
        })
    }
    
    func observeTopPosts(completion: @escaping (Post) -> Void){
        REF_POSTS.queryOrdered(byChild: "likeCount").observeSingleEvent(of: .value, with: {
            snapshot  in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach({ (child) in
                if let dict = child.value as? [String: Any] {
                    let newPost = Post.transformPostPhoto(dict: dict, key: child.key)
                    completion(newPost)
                }
            })
            
        })
        
    }
    
    func observeLikeCount(withPostId id:String, completion: @escaping (Int) -> Void){
    REF_POSTS.child(id).observe(DataEventType.childChanged, with: {
    snapshot in
    if let value = snapshot.value as? Int {
        completion(value)
    }
 })
 }
//トランザクションブロック。by Firebase
    func incrementLikes(postId: String, onSuccess: @escaping (Post)-> Void, onError: @escaping(_ errorMessage: String?)-> Void){
        let postRef = Api.Post.REF_POSTS.child(postId)
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Auth.auth().currentUser?.uid {
                var likes : Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    likeCount += 1
                    likes[uid] = true
                }
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String:Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot!.key)
             onSuccess(post)
                
            }
        }
        
    }
    

}



