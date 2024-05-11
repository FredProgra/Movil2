//
//  DetalleViewController.swift
//  SweaterShopProyec
//
//  Created by DAMII on 11/05/24.
//

import UIKit
import CoreData


class DetalleViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var cantidadTextField: UITextField!
    
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var productoStruct: ProductoStruct?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cantidadTextField.delegate = self
        cantidadTextField.keyboardType = .numberPad
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        // Asegúrate de que un producto fue pasado a DetalleViewController
        guard let productoStruct = productoStruct else { return }

        // Actualiza los elementos de la interfaz de usuario con los detalles del producto
        if let url = URL(string: productoStruct.url) {
            ImageCache.shared.load(url: url, for: imageView)
        }
        
        brandLabel.text = productoStruct.brand
        priceLabel.text = "\(productoStruct.price)"
        sizeLabel.text = productoStruct.size
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == cantidadTextField {
            if let text = textField.text, let cantidad = Int(text), cantidad > 0 {
                return true
            } else {
                // Muestra un mensaje de error al usuario
                print("Por favor, ingresa un número mayor a 0.")
                return false
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == cantidadTextField {
            let maxLength = 5
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return newString.length <= maxLength && allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }



    @IBAction func agregarAlCarrito(_ sender: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        if let text = cantidadTextField.text, let cantidad = Int(text), cantidad > 0 {
            // Crea una instancia de Producto
            let producto = Producto(context: context)
            producto.idProducto = productoStruct?.id
            producto.brand = productoStruct?.brand
            producto.price = productoStruct?.price ?? 0.0
            producto.size = productoStruct?.size
            producto.url = productoStruct?.url

            // Crea una instancia de Carrito si no existe
            let fetchRequest: NSFetchRequest<Carrito> = Carrito.fetchRequest()
            if let carritos = try? context.fetch(fetchRequest), carritos.count > 0 {
                let carrito = carritos[0]
                
                // Comprueba si el producto ya existe en el carrito
                if let items = carrito.items as? Set<ItemCarrito>, let item = items.first(where: { $0.producto?.idProducto == producto.idProducto }) {
                    // Si el producto ya existe, actualiza la cantidad
                    item.cantidad += Int16(cantidad)
                } else {
                    // Si el producto no existe, crea un nuevo ItemCarrito
                    let itemCarrito = ItemCarrito(context: context)
                    itemCarrito.cantidad = Int16(cantidad)
                    itemCarrito.producto = producto
                    carrito.addToItems(itemCarrito)
                }
            } else {
                // Si el carrito no existe, crea un nuevo Carrito y un nuevo ItemCarrito
                let carrito = Carrito(context: context)
                carrito.idCarrito = UUID().uuidString
                
                let itemCarrito = ItemCarrito(context: context)
                itemCarrito.cantidad = Int16(cantidad)
                itemCarrito.producto = producto
                
                carrito.addToItems(itemCarrito)
            }
            
            // Guarda el carrito en Core Data
            do {
                try context.save()
                print("Producto agregado al carrito")
            } catch {
                print("Error al guardar el carrito: \(error)")
            }
        } else {
            // Muestra un mensaje de error al usuario
            print("Por favor, ingresa un número mayor a 0.")
        }
    }



    

}
