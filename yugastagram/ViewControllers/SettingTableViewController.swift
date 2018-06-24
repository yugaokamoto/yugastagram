//
//  SettingTableViewController.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/19.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import SDWebImage
import ProgressHUD
protocol SettingTableViewControllerDelegate {
    func updateUserInfo()
}

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var delegate : SettingTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       fetchCurrentUser()
        usernameTextField.delegate = self
        emailTextField.delegate = self
    }
  
    func fetchCurrentUser(){
        Api.User.observeCurrentUser { (user) in
            self.usernameTextField.text = user.username
            self.emailTextField.text = user.email
            if let profileUrl = URL(string:user.profileImageUrl!){
                self.profileImageView.sd_setImage(with: profileUrl)
            }
        }
    }
   
    @IBAction func saveBtn_touchUpInside(_ sender: Any) {
        if let profileImage = self.profileImageView.image, let imageData = UIImageJPEGRepresentation(profileImage, 0.1){
            ProgressHUD.show("Waiting...")
            AuthService.updateUserInfo(username: usernameTextField.text!, email: emailTextField.text!, imageData: imageData, onSuccess: {
                ProgressHUD.showSuccess("Success")
                self.delegate?.updateUserInfo()
            }) { (errorMessage) in
                ProgressHUD.showError(errorMessage)
            }
        }
        
    }
    
    @IBAction func logOutBtn_touchUpInside(_ sender: Any) {
        AuthService.logOut(onSuccess: {
            let storyboard = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        }) { (errormessage) in
            ProgressHUD.showError(errormessage)
        }
    }
    
    @IBAction func changeProfileBtn_touchUpInside(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
}



extension SettingTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

extension SettingTableViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
        return true
    }
}

