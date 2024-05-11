//
//  RegisterViewController.swift
//  SweaterShopProyec
//
//  Created by DAMII on 5/05/24.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    var overlayView: UIView?

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var password2TextField: UITextField!
    @IBOutlet weak var userFieldText: UITextField!
    
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
        
        
        password2TextField.isSecureTextEntry = true
        let button2 = UIButton(type: .custom)
        button2.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button2.setImage(UIImage(systemName: "eye.fill"), for: .selected)
        button2.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button2.frame = CGRect(x: CGFloat(password2TextField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        button2.addTarget(self, action: #selector(self.togglePasswordVisibility), for: .touchUpInside)
        password2TextField.rightView = button2
        password2TextField.rightViewMode = .always
    }
    
    @objc func togglePasswordVisibility(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        sender.isSelected = !passwordTextField.isSecureTextEntry
    }

    @IBAction func signupClicked(_ sender: UIButton) {
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let password2 = password2TextField.text, !password2.isEmpty,
              let username = userFieldText.text, !username.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Todos los campos son obligatorios.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard isValidEmail(email) else {
            let alert = UIAlertController(title: "Error", message: "El formato del correo no es válido.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
            
        guard password.count >= 6 else {
            let alert = UIAlertController(title: "Error", message: "La contraseña debe tener al menos 6 caracteres.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard password == password2 else {
            let alert = UIAlertController(title: "Error", message: "Las contraseñas no coinciden.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
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
        
        
        Auth.auth().createUser(withEmail: email, password: password) { firebaseResult, error in
            
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.overlayView?.removeFromSuperview()
            
            
            if let e = error {
                print(e)
                let alert = UIAlertController(title: "Error", message: "Hubo un error al crear la cuenta.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "goToNext", sender: self)
            }
        }
    }


    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
