//
//  DetailViewController.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/19.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var postId = ""
    var post = Post()
    var user = User()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPost()
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    func loadPost(){
        Api.Post.observePost(withId: postId) { (post) in
            guard let postUid = post.uid else{
                return
            }
            self.fetchUser(uid: postUid, completed: {
                self.post = post
                self.tableView.reloadData()
            })
        }
        
    }
    
    func fetchUser(uid:String, completed: @escaping () -> Void){
        
        Api.User.observeUser(withId: uid, completion: { user in
            self.user = user
            completed()
        })
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail_CommentVC"{
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "Detail_ProfileUserSegue"{
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

extension DetailViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        cell.user = user
        cell.post = post
        cell.delegate = self
        return cell
    }
    
}

extension DetailViewController:HomeTableViewCellDelegate{
   
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "Detail_CommentVC", sender: postId)
    }
    
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Detail_ProfileUserSegue", sender: userId)
    }
    
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Detail_HashTagSegue", sender: tag)
    }
    
}





