//
//  CameraViewController.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/06.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import ProgressHUD
import AVFoundation

class CameraViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var remove: UIBarButtonItem!
    var selectedImage :UIImage!
    var videoUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handlePost()
    }
    
    func handlePost () {
        if selectedImage != nil{
            self.shareButton.isEnabled = true
            self.remove.isEnabled = true
            self.shareButton.backgroundColor = UIColor.black
        }else{
            self.shareButton.isEnabled = false
            self.remove.isEnabled = true
            self.shareButton.backgroundColor = .lightGray
        }
    }

    @objc func handleSelectPhoto(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image","public.movie"]
        present(pickerController, animated: true, completion: nil)
    }
  
    @IBAction func shareButton_touchUpInside(_ sender: Any) {
        ProgressHUD.show("Wating for...", interaction: false)
        if let profileImage = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImage, 0.1){
           print("size \(profileImage.size)")
            let ratio = profileImage.size.width / profileImage.size.height
            HelperService.uploadDataToServer(data: imageData,videoUrl: self.videoUrl, ratio: ratio, caption: captionTextView.text!, onSuccess:{
            self.clean_items()
            self.tabBarController?.selectedIndex = 0
            })
        }else{
            ProgressHUD.showError("画像を選択してください。")
        }
    }
    
    @IBAction func remove_touchUpInside(_ sender: Any) {
        clean_items()
        handlePost()
    }
    
   
    
    func clean_items(){
        self.captionTextView.text = ""
        self.photo.image = UIImage(named: "placeholder-photo")
        self.selectedImage = nil
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filter_segue"{
            let filterVC = segue.destination as! FilterViewController
            filterVC.selectedImage = self.selectedImage
            filterVC.delegate = self
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
         print("did Finish Picking Media")
         print(info)
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL{
            if let thumbnailImage = self.thumbnailImageForFileUrl(videoUrl){
                selectedImage = thumbnailImage
                photo.image = thumbnailImage
              self.videoUrl = videoUrl
            }
            dismiss(animated: true, completion: nil)
        }
        
        if  let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            selectedImage = image
            photo.image = image
            dismiss(animated: true) {
                self.performSegue(withIdentifier: "filter_segue", sender:  nil)
            }
        }
        
        
    }
    
 
    func thumbnailImageForFileUrl(_ fileUrl:URL) -> UIImage?{
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(6, 3), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        }catch let error{
            print(error)
        }
        return nil
    }
    
    
}

extension CameraViewController:FilterViewControllerDelegate{
    func updatephoto(image: UIImage) {
        self.photo.image = image
    }
    
}
