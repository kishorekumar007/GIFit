//
//  ViewController.swift
//  GIFfit
//
//  Created by kishore Kumar on 27/10/20.
//

import UIKit
import collection_view_layouts

class FavouriteCollectionController: UICollectionViewController {
    
    var favouriteCollectionViewModel:FavouriteCollectionListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(FavouriteGifCell.nib, forCellWithReuseIdentifier: FavouriteGifCell.identifier)
        
        favouriteCollectionViewModel = FavouriteCollectionListViewModel(collectionView: collectionView, viewDelegate: self)

        let layout = FlickrLayout()
        
        layout.delegate = favouriteCollectionViewModel
        layout.cellsPadding = ItemsPadding(horizontal: 8, vertical: 8)
        collectionView?.collectionViewLayout = layout

        // Do any additional setup after loading the view.
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.favouriteCollectionViewModel?.loadFresh()
    }

}

//    MARK: Handler UI notifiacitonn from CollectionViewListViewModel
extension FavouriteCollectionController: ListUIUpdate {
    func shareSheet(source view: UIView?, data: [Any]) {
        self.openShareSheet(data, popFromView: view ?? self.view)

    }
    
    func setDownloadIndicator(enable: Bool) {
        
    }
    
    func setRefreshLoader(_ enabled: Bool) {}
    
    func showMessage(title: String, message: String) {
        self.showAlert(title: title, message: message)
    }
    
    func setBottomLoader(_ enabled: Bool) {}
    
}
