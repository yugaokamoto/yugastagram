//
//  User.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/13.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
class User {
    var email: String?
    var profileImageUrl: String?
    var username: String?
    var id: String?
    var isFollowing:Bool?
}

extension User {
    static func transformUser(dict: [String: Any], key:String) -> User {
        let user = User()
        user.email = dict["email"] as? String
        user.profileImageUrl = dict["profileImageUrl"] as? String
        user.username = dict["username"] as? String
        user.id = key
        
        return user
    }
}
