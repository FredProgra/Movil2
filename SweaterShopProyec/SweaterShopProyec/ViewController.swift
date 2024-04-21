//
//  ViewController.swift
//  SweaterShopProyec
//
//  Created by DAMII on 7/04/24.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var pages: UIPageControl!
    @IBOutlet weak var mycollectionview: UICollectionView!
    var imageArray = ["sweater_white","swaters_verde"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        <#code#>
    }
}
