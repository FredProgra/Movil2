//
//  CarritoViewController.swift
//  SweaterShopProyec
//
//  Created by DAMII on 12/05/24.
//

import UIKit
import CoreData

class CarritoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cantidadProductosLabel: UILabel!
    @IBOutlet weak var totalCarritoLabel: UILabel!
    
    var carrito: Carrito?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50 // Puedes ajustar este valor según tus necesidades

        
        cargarCarrito()
    }
    
    func cargarCarrito() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Carrito> = Carrito.fetchRequest()
        
        do {
            let carritos = try context.fetch(fetchRequest)
            if carritos.count > 0 {
                carrito = carritos[0]
                
                let cantidadProductos = carrito?.items?.count ?? 0
                cantidadProductosLabel.text = "\(cantidadProductos)"

                if let items = carrito?.items?.allObjects as? [ItemCarrito] {
                    let totalCarrito = items.reduce(0, { $0 + (Double($1.cantidad) * ($1.producto?.price ?? 0.0)) })
                    totalCarritoLabel.text = "S/. \(totalCarrito)"
                }


            } else {
                // Si no hay un carrito, crea uno nuevo
                carrito = Carrito(context: context)
                carrito?.idCarrito = UUID().uuidString
                try context.save()
            }
        } catch {
            print("Error al cargar el carrito: \(error)")
        }
        
        // Actualiza la tabla
        tableView.reloadData()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carrito?.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        if let itemCarrito = carrito?.items?.allObjects[indexPath.row] as? ItemCarrito {
            // Configura tu celda con los detalles del ItemCarrito aquí
            if let url = URL(string: itemCarrito.producto?.url ?? "") {
                ImageCache.shared.load(url: url, for: cell.imageViewCarrito)
            }
            cell.brandLabel.text = itemCarrito.producto?.brand
            cell.sizeLabel.text = itemCarrito.producto?.size
            cell.priceLabel.text = "S/. \(itemCarrito.producto?.price ?? 0.0)"
            cell.quantityLabel.text = "\(itemCarrito.cantidad)"
            cell.totalLabel.text = "S/. \((itemCarrito.producto?.price ?? 0.0) * Double(itemCarrito.cantidad))"
        }
        return cell
    }

}
