//
//  SignInViewController.swift
//  yugastagram
//
//  Created by 岡本　優河 on 2018/06/06.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseAuth

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    let bottomLayer = CALayer()
    let bottomLayer2 = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.backgroundColor = UIColor.clear
        emailTextField.tintColor = UIColor.white
        emailTextField.textColor = .white
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor:UIColor(white: 1.0, alpha: 0.6)])
       
        bottomLayer.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        bottomLayer.backgroundColor = UIColor(displayP3Red: 50/225, green: 50/225, blue: 25/225, alpha: 1).cgColor
        
        emailTextField.layer.addSublayer(bottomLayer)
        
        passwordTextField.backgroundColor = UIColor.clear
        passwordTextField.tintColor = UIColor.white
        passwordTextField.textColor = .white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor:UIColor(white: 1.0, alpha: 0.6)])
        
        bottomLayer2.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        bottomLayer2.backgroundColor = UIColor(displayP3Red: 50/225, green: 50/225, blue: 25/225, alpha: 1).cgColor
         passwordTextField.layer.addSublayer(bottomLayer2)
       
        signInButton.isEnabled = false
        
        handleTextField()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defalts = UserDefaults.standard
        let hasViewedWalkthrough = defalts.bool(forKey: "hasViewedWalkthrough")
        
        if hasViewedWalkthrough != true{
            if let pageVC = storyboard?.instantiateViewController(withIdentifier: "WalkthroughPageViewController") as? WalkthroughPageViewController{
                present(pageVC, animated: true, completion: nil)
            }
        }
        
        
        if Auth.auth().currentUser != nil{
            performSegue(withIdentifier: "signInToTabbar", sender: nil)
        }
    }
    
    
    func handleTextField(){
        emailTextField.addTarget(self, action: #selector(SignInViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignInViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        
    }
    
    @objc func textFieldDidChange(){
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else{
            
            signInButton.setTitleColor(UIColor.lightText, for: UIControlState.normal)
            signInButton.isEnabled = false
            return
        }
        signInButton.setTitleColor(.white, for: UIControlState.normal)
        signInButton.isEnabled = true
    }

    
    @IBAction func signIn_touchUpInside(_ sender: Any) {
     view.endEditing(true)
        ProgressHUD.show("Wating for...", interaction: false)
        AuthService.signIn(email: emailTextField.text!, password: passwordTextField.text!, onSuccess:{
            ProgressHUD.showSuccess("Success")
           self.performSegue(withIdentifier: "signInToTabbar", sender: nil)
        }, onError:{error in
            ProgressHUD.showError(error!)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    
    
}
