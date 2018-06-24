//
//  HashtagApi.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/21.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase
class HashApi{
    var REF_HASHTAG = Database.database().reference().child("hashTag")
    func fecthPosts(withTag tag: String, completion: @escaping (String) -> (Void)){
        REF_HASHTAG.child(tag.lowercased()).observe(.childAdded, with: {
           snapshot in
            completion(snapshot.key)
        })
    }
    
}
