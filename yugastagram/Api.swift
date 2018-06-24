//
//  Api.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/15.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
struct Api {
    static var User = UserApi()
    static var Post = PostApi()
    static var Comment = CommentApi()
    static var Post_Comment = Post_CommentApi()
    static var MyPosts = MyPostApi()
    static var Follow = FollowApi()
    static var Feed = FeedApi()
    static var HashTag = HashApi()
    static var Notification = NotificationApi()
}
