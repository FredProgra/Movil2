//
//  ViewController.swift
//  SweaterShopProyec
//
//  Created by DAMII on 7/04/24.
//

import UIKit
import FirebaseDatabase
import CoreData

struct ProductoStruct {
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

class ImageCache {
    var cache = NSCache<NSString, UIImage>()

    static let shared = ImageCache()

    func load(url: URL, for imageView: UIImageView) {
        // Comprueba si la imagen ya está en la caché
        if let image = cache.object(forKey: url.absoluteString as NSString) {
            // Si la imagen está en la caché, úsala
            imageView.image = image
        } else {
            // Si la imagen no está en la caché, descárgala
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        // Guarda la imagen en la caché
                        self?.cache.setObject(image, forKey: url.absoluteString as NSString)
                        // Muestra la imagen
                        imageView.image = image
                    }
                }
            }
        }
    }
}




class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate  {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var overlayView: UIView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var productos: [ProductoStruct] = []
    var todosLosProductos: [ProductoStruct] = []
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5 // Espacio entre las celdas en la misma fila
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5 // Espacio entre las filas de celdas
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5) // Espacio entre las celdas y los bordes de la UICollectionView
            }
        
        activityIndicator.isHidden = true
        
        
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
        
        cargarProductos()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
        
        let context = appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<Carrito> = Carrito.fetchRequest()
            
            do {
                let carritos = try context.fetch(fetchRequest)
                for carrito in carritos {
                    print("Carrito ID: \(carrito.idCarrito ?? "")")
                    if let items = carrito.items as? Set<ItemCarrito> {
                        for item in items {
                            print("Producto ID: \(item.producto?.idProducto ?? ""), Cantidad: \(item.cantidad)")
                        }
                    }
                }
            } catch {
                print("Error al recuperar el carrito: \(error)")
            }
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
            ImageCache.shared.load(url: url, for: cell.imageView)
        }
        else {
            print("URL no válida: \(producto.url)")
        }
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.size.width - 20)/2
        return CGSize(width: size, height: size)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Si el texto de búsqueda está vacío, muestra todos los productos
            productos = todosLosProductos
        } else {
            // Si el texto de búsqueda no está vacío, filtra los productos
            productos = todosLosProductos.filter { $0.brand.lowercased().contains(searchText.lowercased()) }
        }
        
        collectionView.reloadData()
    }

    
    
    func cargarProductos() {
        let ref = Database.database().reference()
        
        ref.child("products").observe(.value, with: { (snapshot) in
            // Obtén los productos del snapshot
            if let productosDict = snapshot.value as? [String: [String: Any]] {
                self.productos = productosDict.map { (key, value) in
                    // Crea un producto a partir de cada entrada en el diccionario
                    return ProductoStruct(id: key, dict: value)
                }
                self.todosLosProductos = self.productos

                
                // Imprime los productos en la consola
                for producto in self.productos {
                    print("ID: \(producto.id), Marca: \(producto.brand), Precio: \(producto.price), Tamaño: \(producto.size), URL: \(producto.url)")
                }
                
                // Recarga la collectionView en el hilo principal
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.overlayView?.removeFromSuperview()
                }
            }
        })
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let productoSeleccionado = productos[indexPath.row]

        let detalleViewController = storyboard?.instantiateViewController(withIdentifier: "DetalleViewController") as! DetalleViewController
        detalleViewController.productoStruct = productoSeleccionado
        
        navigationController?.pushViewController(detalleViewController, animated: true)
    }




   
}
