//
//  RegisterViewController.swift
//  SweaterShopProyec
//
//  Created by DAMII on 28/04/24.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    var overlayView: UIView?
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtPassword2: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        txtPassword.isSecureTextEntry = true
        txtPassword2.isSecureTextEntry = true

    }
    
    @IBAction func newUser(_ sender: UIButton) {
        guard let nombre = txtName.text, !nombre.isEmpty else {
            txtName.becomeFirstResponder()
            mostrarAlerta(mensaje: "El nombre es obligatorio.")
            return
        }
        
        guard let correo = txtEmail.text, !correo.isEmpty else {
            txtEmail.becomeFirstResponder()
            mostrarAlerta(mensaje: "El correo es obligatorio.")
            return
        }
        
        guard let contrasena = txtPassword.text, !contrasena.isEmpty else {
            txtPassword.becomeFirstResponder()
            mostrarAlerta(mensaje: "La contraseña es obligatoria.")
            return
        }
        
        guard let contrasena2 = txtPassword2.text, !contrasena2.isEmpty else {
            txtPassword2.becomeFirstResponder()
            mostrarAlerta(mensaje: "La confirmación de la contraseña es obligatoria.")
            return
        }
        
        guard contrasena == contrasena2 else {
            txtPassword.becomeFirstResponder()
            mostrarAlerta(mensaje: "Las contraseñas no coinciden.")
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
        
        Auth.auth().createUser(withEmail: correo, password: contrasena) { [self] authResult, error in
            overlayView?.removeFromSuperview()
            overlayView = nil

            self.activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
                
            if let error = error {
                // Maneja y muestra el error
                print("Error al registrar al usuario: \(error.localizedDescription)")
                self.mostrarAlerta(mensaje: "Error al registrar al usuario: \(error.localizedDescription)")
                return
            }
            
            // Desempaqueta de manera segura authResult
            if let authResult = authResult {
                // El usuario se ha registrado exitosamente
                // Aquí puedes continuar con tu lógica después del registro
                print("Usuario registrado exitosamente: \(authResult.user.email ?? "")")
                
                // Almacena la información adicional del usuario en Firestore
                let db = Firestore.firestore()
                db.collection("usuarios").document(authResult.user.uid).setData([
                    "nombre": nombre,
                    "correo": correo
                ]) { error in
                    if let error = error {
                        print("Error al agregar información del usuario a Firestore: \(error)")
                    } else {
                        print("Información del usuario agregada a Firestore.")
                    }
                }
                
                self.mostrarAlerta(mensaje: "Usuario registrado exitosamente.")
                
                // Resetea los campos de texto
                self.txtName.text = ""
                self.txtEmail.text = ""
                self.txtPassword.text = ""
                self.txtPassword2.text = ""
                
                self.performSegue(withIdentifier: "HomeSegue", sender: self)

            }
        }
    }


    func mostrarAlerta(mensaje: String) {
        let alerta = UIAlertController(title: nil, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default))
        present(alerta, animated: true)
    }

    
}
