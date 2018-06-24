//
//  FollowApi.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/17.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase

class FollowApi {
    var REF_FOLLOWER = Database.database().reference().child("followers")
    var REF_FOLLOWING = Database.database().reference().child("following")
    
    func followAction(withUser id:String){
        Api.MyPosts.REF_MYPOSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String:Any] {
                for key in dict.keys{
        Database.database().reference().child("feed").child(Auth.auth().currentUser!.uid).child(key).setValue(true)
           }
         }
      })
        REF_FOLLOWER.child(id).child(Auth.auth().currentUser!.uid).setValue(true)
        REF_FOLLOWING.child(Auth.auth().currentUser!.uid).child(id).setValue(true)
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(id).child("\(id)-\(Auth.auth().currentUser!.uid)")
        newNotificationReference.setValue(["from": Auth.auth().currentUser!.uid, "objectId": Auth.auth().currentUser!.uid, "type": "follow", "timestamp": timestamp])
        
    }
    
    func unfollowAction(withUser id:String){
        Api.MyPosts.REF_MYPOSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String:Any] {
                for key in dict.keys{
        Database.database().reference().child("feed").child(Auth.auth().currentUser!.uid).child(key).removeValue()
                }
            }
        })
        
        REF_FOLLOWER.child(id).child(Auth.auth().currentUser!.uid).setValue(NSNull())
        REF_FOLLOWING.child(Auth.auth().currentUser!.uid).child(id).setValue(NSNull())
        
        let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(id).child("\(id)-\(Auth.auth().currentUser!.uid)")
        newNotificationReference.setValue(NSNull())
    }
    
    func isFollowing(userId:String, completed:@escaping (Bool) -> Void){
        REF_FOLLOWER.child(userId).child(Auth.auth().currentUser!.uid).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let _ = snapshot.value as? NSNull{
                completed(false)
            }else{
                completed(true)
            }
        })
    }
    
    func fetchCountFollowing(userId:String, completion: @escaping (Int) -> Void){
        REF_FOLLOWING.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
    func fetchCountFollower(userId:String, completion: @escaping (Int) -> Void){
        REF_FOLLOWER.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }

}



