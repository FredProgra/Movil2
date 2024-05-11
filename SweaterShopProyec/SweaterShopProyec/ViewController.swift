//
//  ViewController.swift
//  SweaterShopProyec
//
//  Created by DAMII on 7/04/24.
//

import UIKit
import FirebaseDatabase

struct Producto {
    let id: String
    let brand: String
    let price: Double
    let size: String
    let url: String
    
    init(id: String, dict: [String: Any]) {
        self.id = id
        self.brand = dict["brand"] as? String ?? ""
        self.price = dict["price"] as? Double ?? 0.0
        self.size = dict["size"] as? String ?? ""
        self.url = dict["url"] as? String ?? ""
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
}



class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    

    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var productos: [Producto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                  
        let ref = Database.database().reference()
                
        ref.child("products").observe(.value, with: { (snapshot) in
            // Obtén los productos del snapshot
            if let productosDict = snapshot.value as? [String: [String: Any]] {
                self.productos = productosDict.map { (key, value) in
                    // Crea un producto a partir de cada entrada en el diccionario
                    return Producto(id: key, dict: value)
                }
                
                // Imprime los productos en la consola
                for producto in self.productos {
                    print("ID: \(producto.id), Marca: \(producto.brand), Precio: \(producto.price), Tamaño: \(producto.size), URL: \(producto.url)")
                }
                
                // Recarga la collectionView en el hilo principal
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        })

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(productos)
        return productos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProductoCollectionViewCell
        
        let producto = productos[indexPath.row]
        cell.brandLabel.text = producto.brand
        
        if let url = URL(string: producto.url) {
            cell.imageView.load(url: url)
        } else {
            print("URL no válida: \(producto.url)")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let size = (collectionView.frame.size.width - 20)/2
            return CGSize(width: size, height: size)
        }


   
}
