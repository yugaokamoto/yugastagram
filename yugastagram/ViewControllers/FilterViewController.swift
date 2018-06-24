//
//  FilterViewController.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/21.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit

protocol FilterViewControllerDelegate {
    func updatephoto(image:UIImage)
}
class FilterViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterPhoto: UIImageView!
    var selectedImage:UIImage!
    var delegate:FilterViewControllerDelegate?
    var context = CIContext(options: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        filterPhoto.image = selectedImage
    }
    
    var CIFilterNames = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectMono",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone"]

    @IBAction func cancelBtm_touchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func nextBtn_touchUpInside(_ sender: Any) {
        delegate?.updatephoto(image: self.filterPhoto.image!)
        dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(image:UIImage, newWidth:CGFloat) -> UIImage{
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage!
    }
}



extension FilterViewController :UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CIFilterNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
       let newImage = resizeImage(image: selectedImage, newWidth: 150)
        let ciImage = CIImage(image: newImage)
        let filter = CIFilter(name: CIFilterNames[indexPath.item])
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        if let filteredImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage{
            let result = context.createCGImage(filteredImage, from: filteredImage.extent)
             cell.filterPhoto.image = UIImage(cgImage: result!)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ciImage = CIImage(image: selectedImage)
        let filter = CIFilter(name: CIFilterNames[indexPath.item])
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        if let filteredImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage{
             let result = context.createCGImage(filteredImage, from: filteredImage.extent)
            self.filterPhoto.image = UIImage(cgImage: result!)
}

    }

}
