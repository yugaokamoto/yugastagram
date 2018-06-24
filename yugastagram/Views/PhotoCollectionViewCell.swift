//
//  PhotoCollectionViewCell.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/17.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
protocol PhotoCollectionViewCellDelegate {
    func goToDetailUserVC(postId: String)
}
class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    var delegate:PhotoCollectionViewCellDelegate?
    var post : Post?{
        didSet{
            updateView()
        }
    }
    
    func updateView(){
        if let photoUrlString = post?.photoUrl{
            let photoUrl = URL(string: photoUrlString)
            photo.sd_setImage(with: photoUrl)
        }
        
        let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.photo_TouchUpInside))
        photo.addGestureRecognizer(tapGestureForPhoto)
        photo.isUserInteractionEnabled = true
    }
    
    @objc func photo_TouchUpInside(){
        if let id = post?.id{
            delegate?.goToDetailUserVC(postId: id)
        }
    }
    
}


