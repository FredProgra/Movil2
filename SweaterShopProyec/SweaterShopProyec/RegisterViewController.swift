//
//  RegisterViewController.swift
//  SweaterShopProyec
//
//  Created by DAMII on 5/05/24.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.isSecureTextEntry = true
    }
    


    @IBAction func signupClicked(_ sender: UIButton) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password)
        {firebaseResult, error in
            
            if let e = error {
                print(error)
            }
            else{
                self.performSegue(withIdentifier: "goToNext", sender: self)
            }
        }
    }

}
