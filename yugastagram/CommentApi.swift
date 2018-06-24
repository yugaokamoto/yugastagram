//
//  CommentApi.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/15.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase
class CommentApi{
    var REF_COMMENTS = Database.database().reference().child("comments")
    
    func observeComments(withPostId id: String,completion: @escaping (Comment) -> Void){
        REF_COMMENTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let newComment = Comment.transformComment(dict: dict)
            completion(newComment)
            }
        })
    }
    
    
}
