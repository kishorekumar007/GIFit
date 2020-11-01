//
//  FavouriteCollectionListModel.swift
//  GIFfit
//
//  Created by kishore Kumar on 31/10/20.
//

import Foundation
import UIKit
import collection_view_layouts

class FavouriteCollectionListViewModel: CommonListViewModel {
    
    private var dataSource:UICollectionViewDiffableDataSource<String, GifCellViewModel>!

    weak var collectionView:UICollectionView?
    
    init(collectionView:UICollectionView, viewDelegate:ListUIUpdate) {
        super.init(delegate: viewDelegate)
        self.collectionView = collectionView
        self.collectionView?.delegate = self
    }
        
    private func makeDataSource(collectionView:UICollectionView) -> UICollectionViewDiffableDataSource<String, GifCellViewModel> {
        return UICollectionViewDiffableDataSource.init(collectionView: collectionView) {  collectionView, indexPath, viewModel in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavouriteGifCell.identifier, for: indexPath) as? FavouriteGifCell
            cell?.setupCell(for: viewModel)
            return cell
        }
        
    }

    override func clearData() {
        guard self.viewModels.count != 0 else {return}
        super.clearData()
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        dataSource.apply(snapshot)
    }
    
    override func insert(models: [GifCellViewModel]) {
        clearData()
        super.insert(models: models)

        var snapshot = NSDiffableDataSourceSnapshot<String, GifCellViewModel>()
        snapshot.appendSections([AppConstants.shared.listSectionId])
        snapshot.appendItems(viewModels)
        dataSource.apply(snapshot, animatingDifferences: false)

    }
    override func beforeUpdate(oldModel: GifCellViewModel) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([oldModel])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    override func updated(newModel: GifCellViewModel) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.shared.didUpdateNotification), object: newModel)
    }

    func loadFresh() {
        guard let favIds = UserDefaults.standard.favourites else {
            return
        }
        self.dataSource = makeDataSource(collectionView: collectionView!)
        self.collectionView?.dataSource = self.dataSource
        fetch(type: .favourite(gifIds: favIds), dataSource: self)
    }
    
}

extension FavouriteCollectionListViewModel: LayoutDelegate {
    
    func cellSize(indexPath: IndexPath) -> CGSize {
        guard let size = viewModels[0].size else {
            return .zero
        }
        return size
    }
    
}

extension FavouriteCollectionListViewModel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard var viewModel = dataSource.itemIdentifier(for: indexPath) else {return nil}
        return viewModel.getContextMenuConfig(for: dataSource.collectionView(collectionView, cellForItemAt: indexPath)) { () -> UIViewController? in
            PreviewController(viewModel: viewModel)
        }
    }
}

