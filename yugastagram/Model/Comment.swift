//
//  Comment.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/15.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
class Comment {
    var commentText: String?
    var uid: String?
}

extension Comment {
    static func transformComment(dict: [String: Any]) -> Comment {
        let comment = Comment()
        comment.commentText = dict["commentText"] as? String
        comment.uid = dict["uid"] as? String
        return comment
    }
}
