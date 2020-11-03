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
    var refreshControl:UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationItem.largeTitleDisplayMode = .always

        collectionView.register(FavouriteGifCell.nib, forCellWithReuseIdentifier: FavouriteGifCell.identifier)
        
        favouriteCollectionViewModel = FavouriteCollectionListViewModel(collectionView: collectionView, viewDelegate: self)
        
        refreshControl = UIRefreshControl.init(frame: .zero)
        refreshControl?.addTarget(favouriteCollectionViewModel, action: #selector(FavouriteCollectionListViewModel.loadFresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        let layout = FlickrLayout()
        layout.delegate = favouriteCollectionViewModel
        layout.cellsPadding = ItemsPadding(horizontal: 8, vertical: 8)
        collectionView?.collectionViewLayout = layout

        self.favouriteCollectionViewModel?.loadFresh()

        // Do any additional setup after loading the view.
    }
 
    override func viewWillAppear(_ animated: Bool) {
        if view.tag == 1 {
            self.favouriteCollectionViewModel?.updateDiff()
        }
        view.tag = 1
        super.viewWillAppear(animated)
    }

}

//    MARK: Handler UI notifiacitonn from CollectionViewListViewModel
extension FavouriteCollectionController: ListUIUpdate {
    func pushPreviewController(model: GifCellViewModel) {
        self.navigationController?.pushViewController(PreviewController(viewModel: model), animated: true)
    }
    
    func shareSheet(source view: UIView?, data: [Any]) {
        self.openShareSheet(data, popFromView: view ?? self.view)

    }
    
    func setDownloadIndicator(enable: Bool) {
        
    }
    
    func setRefreshLoader(_ enabled: Bool) {
        if enabled {
            refreshControl?.beginRefreshing()
        }
        else {
            refreshControl?.endRefreshing()
        }
    }
    
    func showMessage(title: String, message: String) {
        self.showAlert(title: title, message: message)
    }
    
    func setBottomLoader(_ enabled: Bool) {}
    
}
