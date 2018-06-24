//
//  CommentViewController.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/14.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import ProgressHUD


class CommentViewController: UIViewController {

    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
 
    var postId :String!
    var comments = [Comment]()
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Comment"
        tableView.dataSource = self
        tableView.estimatedRowHeight = 77
        tableView.rowHeight = UITableViewAutomaticDimension
        sendButton.isEnabled = false
        handleTextField()
        empty()
        loadComments()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        let keyboardframe = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3) {
            self.constraintToBottom.constant = keyboardframe!.height
            self.view.layoutIfNeeded()
        }
    }
    
    
    @objc func keyboardWillHide(_ notification: NSNotification){
         print(notification)
        UIView.animate(withDuration: 0.3) {
            self.constraintToBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func loadComments(){
      
    Api.Post_Comment.REF_POST_COMMENTS.child(self.postId!).observe(.childAdded, with: {
              snapshot in
           
            Api.Comment.observeComments(withPostId: snapshot.key, completion: { comment in
                self.fetchUser(uid: comment.uid!, completed: {
                    self.comments.append(comment)
                    self.tableView.reloadData()
                })
            })
        })
    }
    
    func fetchUser(uid: String, completed:  @escaping () -> Void ) {
      
        Api.User.observeUser(withId: uid, completion: { user in
            self.users.append(user)
            completed()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    func handleTextField() {
        commentTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        if let commentText = commentTextField.text, !commentText.isEmpty {
            sendButton.setTitleColor(UIColor.black, for: UIControlState.normal)
            sendButton.isEnabled = true
            return
        }
        sendButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
        sendButton.isEnabled = false
    }
    
    @IBAction func sendButton_touchUpInside(_ sender: Any) {

        let commentReference = Api.Comment.REF_COMMENTS
        let newCommentId = commentReference.childByAutoId().key
        let newcommentReference = commentReference.child(newCommentId)
        //newpostReference = Database.database().reference().child("Posts").child(newPostId)
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let currentUserId = currentUser.uid
        newcommentReference.setValue(["uid": currentUserId,"commentText": commentTextField.text!], withCompletionBlock: { (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            let words = self.commentTextField.text!.components(separatedBy: CharacterSet.whitespaces)
            
            for var word in words{
                if word.hasPrefix("#"){
                    word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                    let newHashTagRef = Api.HashTag.REF_HASHTAG.child(word.lowercased())
                    newHashTagRef.updateChildValues([self.postId!:true])
                    print(self.postId!)
                }
            }
          
            
            let postCommentRef = Api.Post_Comment.REF_POST_COMMENTS.child(self.postId!).child(newCommentId)
            postCommentRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                Api.Post.observePost(withId: self.postId, completion: { (post) in
                    if post.uid! != Auth.auth().currentUser!.uid {
                        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
                        let newNotificationId = Api.Notification.REF_NOTIFICATION.child(post.uid!).childByAutoId().key
                        let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(post.uid!).child(newNotificationId)
                        newNotificationReference.setValue(["from": Auth.auth().currentUser!.uid, "objectId": self.postId!, "type": "comment", "timestamp": timestamp])
                    }
                })
            })
            self.empty()
            self.view.endEditing(true)
        })
        
    }
   
    func empty(){
        self.commentTextField.text = ""
        self.sendButton.isEnabled = false
        self.sendButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Comment_ProfileSegue"{
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Comment_HashTagSegue"{
            let hashTagVC = segue.destination as! HashTagViewController
            let tag = sender as! String
            hashTagVC.tag = tag
        }

    }
    

}


extension CommentViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        let comment = comments[indexPath.row]
        let user = users[indexPath.row]
        cell.comment = comment
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension CommentViewController:CommentTableViewCellDelegate{
    func goToProfileUserVC(userId: String) {
     performSegue(withIdentifier: "Comment_ProfileSegue", sender: userId)
    }
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Comment_HashTagSegue", sender: tag)
    }
}






