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
    
    var isLoadFresh:Bool = true
    
    init(collectionView:UICollectionView, viewDelegate:ListUIUpdate) {
        super.init(delegate: viewDelegate)
        self.collectionView = collectionView
        self.collectionView?.delegate = self
        self.dataSource = makeDataSource(collectionView: collectionView)
        self.collectionView?.dataSource = self.dataSource
    }
        
    private func makeDataSource(collectionView:UICollectionView) -> UICollectionViewDiffableDataSource<String, GifCellViewModel> {
        return UICollectionViewDiffableDataSource.init(collectionView: collectionView) {  collectionView, indexPath, viewModel in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavouriteGifCell.identifier, for: indexPath) as? FavouriteGifCell
            cell?.setupCell(for: self.viewModels[indexPath.row])
            return cell
        }
        
    }

    override func clearData() {
        guard !self.viewModels.isEmpty else {return}
        super.clearData()
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        dataSource.apply(snapshot)
    }
    
    override func insert(models: [GifCellViewModel]) {
        delegate?.setRefreshLoader(false)
        if isLoadFresh {
            clearData()
        }
        super.insert(models: models)

        var snapshot = NSDiffableDataSourceSnapshot<String, GifCellViewModel>()
        snapshot.appendSections([AppConstants.shared.listSectionId])
        snapshot.appendItems(viewModels)
        dataSource.apply(snapshot, animatingDifferences: false)

    }
    override func beforeUpdate(oldModel: GifCellViewModel) {
        var snapshot = dataSource.snapshot()
        self.viewModels.removeAll(where: {$0 == oldModel})
        snapshot.deleteItems([oldModel])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    override func updated(newModel: GifCellViewModel) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.shared.didUpdateNotification), object: newModel)
    }

    @objc func loadFresh() {
        delegate?.setRefreshLoader(true)
        
        guard let favIds = UserDefaults.standard.favourites, !favIds.isEmpty  else {
            delegate?.setRefreshLoader(false)
            return
        }
        isLoadFresh = true
        fetch(type: .favourite(gifIds: favIds), dataSource: self)
    }
    
    func updateDiff() {

        delegate?.setRefreshLoader(true)
        
        guard let favIds = UserDefaults.standard.favourites, !favIds.isEmpty  else {
            delegate?.setRefreshLoader(false)
            return
        }
        
        let deleted = viewModels.filter({!favIds.contains($0.id)})
        deleted.forEach({self.beforeUpdate(oldModel: $0)})
        
        let ids = viewModels.map({$0.id})
        let inserted = favIds.filter({!ids.contains($0)})
        isLoadFresh = false
        
        guard !inserted.isEmpty else {
            delegate?.setRefreshLoader(false)
            return
        }
        
        fetch(type: .favourite(gifIds: inserted), dataSource: self)

    }
    
    func fetchDiff(ids:[String]) {
        
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
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addAnimations {
            guard let id = configuration.identifier as? NSString, let model = self.viewModels.first(where: {$0.id == id as String}) else{
                return
            }
            self.delegate?.pushPreviewController(model: model)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.pushPreviewController(model: viewModels[indexPath.row])
    }

}

