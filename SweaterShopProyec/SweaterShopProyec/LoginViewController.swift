//
//  LoginViewController.swift
//  SweaterShopProyec
//
//  Created by DAMII on 5/05/24.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    var overlayView: UIView?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true

        passwordTextField.isSecureTextEntry = true
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.setImage(UIImage(systemName: "eye.fill"), for: .selected)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(passwordTextField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        button.addTarget(self, action: #selector(self.togglePasswordVisibility), for: .touchUpInside)
        passwordTextField.rightView = button
        passwordTextField.rightViewMode = .always
    }
    
    @objc func togglePasswordVisibility(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        sender.isSelected = !passwordTextField.isSecureTextEntry
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        // Crea la vista de superposición
        overlayView = UIView(frame: view.bounds)
        overlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // Añade la vista de superposición a la vista
        view.addSubview(overlayView!)

        // Asegúrate de que el indicador de actividad esté al frente
        view.bringSubviewToFront(activityIndicator)

        // Inicia el indicador de actividad
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        
        Auth.auth().signIn(withEmail: email, password: password)
        {firebaseResult, error in
            
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.overlayView?.removeFromSuperview()
            
            if let e = error {
                print(e)
                let alert = UIAlertController(title: "Error", message: "Credenciales incorrectas.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "goToNext", sender: self)
            }
        }
    }

}
