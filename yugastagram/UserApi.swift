//
//  UserApi.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/15.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserApi {
    var REF_USERS = Database.database().reference().child("users")
    
    func observeUserByUsername(username:String,completion: @escaping (User) -> Void){
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryEqual(toValue: username).observeSingleEvent(of: .childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
        }
    })
}
    
    func observeUser(withId uid: String, completion: @escaping (User) -> Void){
        REF_USERS.child(uid).observeSingleEvent(of: DataEventType.value) { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
        }
    }
  }
    func observeCurrentUser(completion: @escaping (User) -> Void){
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: DataEventType.value) { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        }
    }
    
    func observeUsers(completion: @escaping (User) -> Void){
        REF_USERS.observe(DataEventType.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                if user.id != Auth.auth().currentUser?.uid{
                     completion(user)
                }
            }
        })
    }
    
    func queryUser(withText text: String,completion: @escaping (User) -> Void){
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").queryLimited(toFirst: 2).observeSingleEvent(of: .value, with: {
            snapshot in
            snapshot.children.forEach({ (s) in
                let child = s as! DataSnapshot
                if let dict = child.value as? [String: Any] {
                    let user = User.transformUser(dict: dict, key: child.key)
                    completion(user)
                }
            })
        })
    }
    
    
//    サンプルでは通っているが、通らない。
//    var CRRENT_USER : User?{
//        if let currentUser = Auth.auth().currentUser{
//            return currentUser
//        }
//        return nil
//    }
//    エラーコード
//    Cannot convert return expression of type 'User' to return type 'User?'
    
    
    var REF_CRRENT_USER: DatabaseReference?{
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        
        return REF_USERS.child(currentUser.uid)
    }
    
}
