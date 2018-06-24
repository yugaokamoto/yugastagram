//
//  HeaderProfileCollectionReusableView.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/17.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import Firebase
protocol HeaderProfileCollectionReusableViewDelegate {
    func updateFollowbutton(forUser user : User)
}
protocol HeaderProfileCollectionReusableViewDelegateSwitchSettingVC{
    func goToSettingVC()
}

class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var myPostCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    var delegate:HeaderProfileCollectionReusableViewDelegate?
    var delegate2:HeaderProfileCollectionReusableViewDelegateSwitchSettingVC?
    
    var user:User?{
        didSet{
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clear()
    }
    
    
    func updateView(){
            self.nameLabel.text = user!.username
            if let photoUrlString = user!.profileImageUrl{
                let photoUrl = URL(string: photoUrlString)
                self.profileImage.sd_setImage(with: photoUrl)
        }
        
        Api.MyPosts.fetchMyPostCount(userId: user!.id!, completion: {
            count in
            self.myPostCountLabel.text = "\(count)"
        })
        Api.Follow.fetchCountFollowing(userId: user!.id!) { (count) in
            self.followingCountLabel.text = "\(count)"
        }
        Api.Follow.fetchCountFollower(userId: user!.id!) { (count) in
            self.followerCountLabel.text = "\(count)"
        }
        
        if user?.id == Auth.auth().currentUser?.uid{
            followButton.setTitle("Edit Profile", for: UIControlState.normal)
            followButton.addTarget(self, action: #selector(self.goToSettingVC), for: UIControlEvents.touchUpInside)
            
        }else{
            updateStateFollowButton()
        }
    }
    
    func clear(){
        self.nameLabel.text = ""
        self.myPostCountLabel.text = ""
        self.followerCountLabel.text = ""
        self.followerCountLabel.text = ""
        
    }
    
    @objc func goToSettingVC(){
        delegate2?.goToSettingVC()
    }
    
    func updateStateFollowButton(){
        if user?.isFollowing == true {
            configureUnFollowButton()
        }else{
            configureFollowButton()
        }
    }
    
    
    func configureFollowButton(){
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(displayP3Red: 226/255, green: 228/255, blue: 233/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        followButton.backgroundColor = UIColor.clear
        followButton.setTitle("Follow", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControlEvents.touchUpInside)
    }
    
    func configureUnFollowButton(){
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(displayP3Red: 226/255, green: 228/255, blue: 233/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        followButton.backgroundColor = UIColor.blue
        followButton.setTitle("Following", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControlEvents.touchUpInside)
    }
    
    @objc func followAction() {
        if user?.isFollowing! == false{
            Api.Follow.followAction(withUser: user!.id!)
            configureUnFollowButton()
            user?.isFollowing! = true
            delegate?.updateFollowbutton(forUser: user!)
        }
        
    }
    
    @objc func unFollowAction(){
        if user?.isFollowing! == true{
            Api.Follow.unfollowAction(withUser: user!.id!)
            configureFollowButton()
            user?.isFollowing! = false
        }
        
    }
    
}
