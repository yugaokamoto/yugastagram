//
//  HomeViewController.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/06.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import SDWebImage
import ProgressHUD
import Firebase

class HomeViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityViewIndicater: UIActivityIndicatorView!
    var posts = [Post]()
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        
       loadPost()
    }

    func loadPost(){
        
        Api.Feed.observeFeed(withId: Auth.auth().currentUser!.uid) {
            (post) in
            guard let postUid = post.uid else {
                return
            }
            self.fetchUser(uid: postUid, completed: {
            self.posts.insert(post, at: 0)
            self.activityViewIndicater.stopAnimating()
            self.tableView.reloadData()
                            })
        }
        
        Api.Feed.observeFeedRemove(withId: Auth.auth().currentUser!.uid) { (post) in
            self.posts = self.posts.filter{$0.id != post.id}
            self.users = self.users.filter{$0.id != post.uid}
            self.tableView.reloadData()
        }
  }

    func fetchUser(uid:String, completed: @escaping () -> Void){
       
        Api.User.observeUser(withId: uid, completion: { user in
            self.users.insert(user, at: 0)
            completed()
        })
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue"{
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "Home_ProfileSegue"{
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Home_HashTagSegue"{
            let hashTagVC = segue.destination as! HashTagViewController
            let tag = sender as! String
            hashTagVC.tag = tag
        }
    }
}

extension HomeViewController: UITableViewDataSource,UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        
        cell.user = user
        cell.post = post
        cell.delegate = self
        return cell
    }
}

extension HomeViewController:HomeTableViewCellDelegate{
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Home_ProfileSegue", sender: userId)
    }
    
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "CommentSegue", sender: postId)
    }
    
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Home_HashTagSegue", sender: tag)
    }
    
}


