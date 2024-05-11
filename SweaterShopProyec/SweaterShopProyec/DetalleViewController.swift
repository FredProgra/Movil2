//
//  DetalleViewController.swift
//  SweaterShopProyec
//
//  Created by DAMII on 11/05/24.
//

import UIKit

class DetalleViewController: UIViewController {
    
    var producto: Producto?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let producto = producto {
            print("Producto seleccionado: \(producto)")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
