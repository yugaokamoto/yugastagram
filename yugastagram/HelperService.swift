//
//  HelperService.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/17.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase
import ProgressHUD

class HelperService{
    static func uploadDataToServer(data:Data, videoUrl:URL? = nil, ratio:CGFloat, caption: String,onSuccess: @escaping  () -> Void){
        if let videoUrl = videoUrl {
            self.uploadVideoToFirebaseStorage(videoUrl: videoUrl) { (videoUrl) in
                uploadImageToFirebaseStorage(data: data, onSuccess: { (thumbnailImageUrl) in
                    sendDataToDatabase(photoUrl: thumbnailImageUrl,ratio: ratio, videoUrl:videoUrl, caption: caption, onSuccess:onSuccess
                    )
                })
            }
        }else{
            uploadImageToFirebaseStorage(data: data) { (photoUrl) in
                self.sendDataToDatabase(photoUrl: photoUrl, ratio: ratio, caption: caption, onSuccess: onSuccess)
            }
        }
    }
    static func uploadVideoToFirebaseStorage(videoUrl:URL,onSuccess:  @escaping  (_ videoUrl:String) -> Void){
        let videoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: config.STORAGE_ROOF_REF ).child("posts").child(videoIdString)
        storageRef.putFile(from: videoUrl, metadata: nil) { (metadata, error) in
            if error != nil{
                return
            }
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                if let videoUrl = url?.absoluteString {
                    onSuccess(videoUrl)
                }
            })
        }
    }
    
    static func uploadImageToFirebaseStorage(data: Data, onSuccess:  @escaping  (_ imageUrl:String) -> Void){
        let photoIDString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: config.STORAGE_ROOF_REF ).child("posts").child(photoIDString)
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if error != nil{
                return
            }
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                if let photoUrl = url?.absoluteString {
                    onSuccess(photoUrl)
                }
            })
        }
    }
    static func sendDataToDatabase(photoUrl:String,ratio:CGFloat, videoUrl:String? = nil, caption: String,onSuccess: @escaping  () -> Void ){
        let newPostId = Api.Post.REF_POSTS.childByAutoId().key
        let newpostReference = Api.Post.REF_POSTS.child(newPostId)
        
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let currentUserId = currentUser.uid
        
        let words = caption.components(separatedBy: CharacterSet.whitespaces)
        
        for var word in words{
            if word.hasPrefix("#"){
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                let newHashTagRef = Api.HashTag.REF_HASHTAG.child(word.lowercased())
                newHashTagRef.updateChildValues([newPostId:true])
            }
        }
        let timestamp = Int(Date().timeIntervalSince1970)
        print(timestamp)
        var dict = ["uid": currentUserId,"photoUrl": photoUrl,"caption": caption ,"likeCount": 0, "ratio": ratio,"timestamp": timestamp] as [String : Any]
        if let videoUrl = videoUrl{
            dict["videoUrl"] = videoUrl
        }
        
        newpostReference.setValue(dict, withCompletionBlock: { (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            Api.Feed.REF_FEED.child(Auth.auth().currentUser!.uid).child(newPostId).setValue([])
            Api.Follow.REF_FOLLOWER.child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: {
                snapshot in
                let arraysnapshot = snapshot.children.allObjects as! [DataSnapshot]
                arraysnapshot.forEach({ (child) in
                  print(child.key)
                    Api.Feed.REF_FEED.child(child.key).updateChildValues(["\(newPostId)":true])
                    let newNotificationId = Api.Notification.REF_NOTIFICATION.child(child.key).childByAutoId().key
                    let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(child.key).child(newNotificationId)
                    newNotificationReference.setValue(["from":Auth.auth().currentUser!.uid, "type":"feed", "objectId":newPostId,"timestamp":timestamp])
                })
            })
            
            let myPostsRef = Api.MyPosts.REF_MYPOSTS.child(currentUserId).child(newPostId)
            myPostsRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            
            ProgressHUD.showSuccess("Success")
            onSuccess()
        })
        
        
    }
    
    
    
}






