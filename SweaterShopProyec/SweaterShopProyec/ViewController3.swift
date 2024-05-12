//
//  ViewController3.swift
//  SweaterShopProyec
//
//  Created by DAMII on 11/05/24.
//

import UIKit
import FirebaseDatabase
import Firebase

struct datesStruct{
    let userID: String
    let name: String
    let firstName: String
    let numCard: String
    let expCard: String
    let cvvCard: String
    let direction: String
    let monto: String
    
    init(userID: String, dict: [String: Any]) {
        self.userID = userID
        self.name = dict["name"] as? String ?? ""
        self.firstName = dict["firstName"] as? String ?? ""
        self.numCard = dict["numCard"] as? String ?? ""
        self.expCard = dict["expCard"] as? String ?? ""
        self.cvvCard = dict["cvvCard"] as? String ?? ""
        self.direction = dict["direction"] as? String ?? ""
        self.monto = dict["mount"] as? String ?? ""
    }
}

class ViewController3: UIViewController{
    
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var Monto: UITextField!
    @IBOutlet weak var txtdireccion: UITextField!
    @IBOutlet weak var txtcvv: UITextField!
    @IBOutlet weak var txtvencimiento: UITextField!
    @IBOutlet weak var txtnrotarjeta: UITextField!
    @IBOutlet weak var txtapellidos: UITextField!
    @IBOutlet weak var txtnombre: UITextField!
    
    var overlayView: UIView?
    var datosFacturacion: [datesStruct] = []
    var todosDatosFacturacion : [datesStruct] = []
    var ref: DatabaseReference
        
    required init?(coder aDecoder: NSCoder) {
        ref = Database.database().reference()
        super.init(coder: aDecoder)
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        //cargarDatosFacturacion()
    }
    
    
    
    @IBAction func btnpagar(_ sender: UIButton) {
        
        guardarDatosFacturacion()
        
    }
    
    func cargarDatosFacturacion() {
        let ref = Database.database().reference()
        
        ref.child("datosFacturacion").observe(.value, with: { (snapshot) in
            if let datosFacturacionDict = snapshot.value as? [String: [String: Any]] {
                self.datosFacturacion = datosFacturacionDict.map { (key, value) in
                    return datesStruct(userID: key, dict: value)
                }
                self.todosDatosFacturacion = self.datosFacturacion
                
                
                for datosFacturacion in self.datosFacturacion {
                    print("userID: \(datosFacturacion.userID), Nombre: \(datosFacturacion.name), Apellido: \(datosFacturacion.firstName), Numero de Tarjeta: \(datosFacturacion.numCard), Fecha de Vencimiento: \(datosFacturacion.expCard), CVV: \(datosFacturacion.cvvCard), Direccion: \(datosFacturacion.direction), Monto: \(datosFacturacion.monto)")
                }
                
                DispatchQueue.main.async {
                    self.txtnombre.text = self.datosFacturacion.first?.name
                    
                    self.txtapellidos.text = self.datosFacturacion.first?.firstName
                    
                    self.txtnrotarjeta.text = self.datosFacturacion.first?.numCard
                    
                    self.txtvencimiento.text = self.datosFacturacion.first?.expCard
                    
                    self.txtcvv.text = self.datosFacturacion.first?.cvvCard
                    
                    self.txtdireccion.text = self.datosFacturacion.first?.direction
                    
                    self.Monto.text = self.datosFacturacion.first?.monto
                    
                    self.ActivityIndicator.stopAnimating()
                    self.ActivityIndicator.isHidden = true
                    self.overlayView?.removeFromSuperview()
                }
            }
        })
    }
    
    func guardarDatosFacturacion() {
        guard let name = txtnombre.text, !name.isEmpty,
              let firstname = txtapellidos.text, !firstname.isEmpty,
              let numCard = txtnrotarjeta.text, !numCard.isEmpty,
              let expCard = txtvencimiento.text, !expCard.isEmpty,
              let cvvCard = txtcvv.text, !cvvCard.isEmpty,
              let direction = txtdireccion.text, !direction.isEmpty,
              let mount = Monto.text, !mount.isEmpty
        else{
            let alert = UIAlertController(title: "Error", message: "Todos los campos son obligatorios.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let datosFacturacionRef = ref.child("datosFacturacion").child(userID)
        
        let datos: [String: Any] = [
            "name": txtnombre.text ?? "",
            "firstName": txtapellidos.text ?? "",
            "numCard": txtnrotarjeta.text ?? "",
            "expCard": txtvencimiento.text ?? "",
            "cvvCard": txtcvv.text ?? "",
            "direction": txtdireccion.text ?? "",
            "mount": Monto.text ?? ""
        ]
        
        datosFacturacionRef.setValue(datos) { (error, ref) in
            if let error = error {
                print("Error al guardar los datos de facturación: \(error.localizedDescription)")                
            } else {
                print("Datos de facturación guardados correctamente")
                self.mostrarAlerta()
            }
        }
    }
    
    func mostrarAlerta() {
        let alert = UIAlertController(title: "Pago Realizado", message: "Se efectuó el pago correctamente.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
