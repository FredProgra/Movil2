//
//  ViewController.swift
//  SweaterShopProyec
//
//  Created by DAMII on 7/04/24.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var pages: UIPageControl!
    @IBOutlet weak var mycollectionView: UICollectionView!
    var imageArray = ["sweaters_verde","sweater_white"]
    var index = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(scrollingsetup), userInfo: nil, repeats: true)
    }
    @objc func scrollingsetup(){
        if index < imageArray.count - 1{
            index = index + 1
        }else{
            index = 0
        }
        pages.numberOfPages = imageArray.count
        pages.currentPage = index
        mycollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .right, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as? CustomCollectionViewCell
        cell?.adsImage.image = UIImage(named: imageArray[indexPath.row])
        cell?.layer.borderWidth = 1
        cell?.layer.borderColor = UIColor.white.cgColor
        cell?.layer.cornerRadius = 20
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
