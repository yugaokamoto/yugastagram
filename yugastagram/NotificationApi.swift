//
//  NotificationApi.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/22.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase

class NotificationApi {
    var REF_NOTIFICATION = Database.database().reference().child("notification")
    
    func observeNotification(withId id:String,completion: @escaping (Notification) -> Void){
        REF_NOTIFICATION.child(id).observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String:Any]{
                let newNoti = Notification.transform(dict: dict, key: snapshot.key)
                completion(newNoti)
            }
        })
    }
   
}
