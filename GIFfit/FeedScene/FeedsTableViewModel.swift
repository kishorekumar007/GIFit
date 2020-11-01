//
//  FeedsViewModel.swift
//  GIFfit
//
//  Created by kishore Kumar on 27/10/20.
//

import Foundation
import UIKit


class FeedTableModel:CommonListViewModel {
    
    private var fetchType:FetchType = .trend(offset: 0, limit: AppConstants.shared.limit)

    private var dataSource:UITableViewDiffableDataSource<String, GifCellViewModel>!
    
    private weak var tableView:UITableView?
    
    private var offset:Int = 0
    
    
    /// Search bar type interval
    var tempTime:Timer?

    //    MARK: Init
    /// Init the table list view model
    /// - Parameters:
    ///   - tableView: tableview instant
    ///   - viewDelegate: view update listener
    init(tableView:UITableView, viewDelegate:ListUIUpdate) {
        self.tableView = tableView
        
        super.init(delegate: viewDelegate)
        
        self.dataSource = self.makeDataSource(tableView: tableView)
        self.tableView?.dataSource = dataSource

        self.tableView?.delegate = self
        
        self.loadFresh(type: fetchType)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadDataSource(notification:)), name: NSNotification.Name(rawValue: AppConstants.shared.didUpdateNotification), object: nil)
    }
    
    //    MARK: Table Data source
    private func makeDataSource(tableView:UITableView) -> UITableViewDiffableDataSource<String, GifCellViewModel> {
        
        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, viewModel in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: FeedTableCell.identifier,
                    for: indexPath
                ) as? FeedTableCell
                cell?.setup(viewModel: self.viewModels[indexPath.row])
                print(viewModel.id, viewModel.isFavourite)
                return cell
            }
        )
    }
    
    //    MARK: Data handling
    
    //    MARK: Common data handling after got ViewModel
    
    /// Clear data if type changed
    override func clearData() {
        super.clearData()
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        dataSource.apply(snapshot)
        offset = 0
    }
    
    
    /// Insert viewmode in datasoruce
    /// - Parameter models: Models
    override func insert(models: [GifCellViewModel]) {
        if offset == 0 {
            clearData()
        }
        super.insert(models: models)
        print(viewModels.map({$0.id}))

        var snapshot = NSDiffableDataSourceSnapshot<String, GifCellViewModel>()
        snapshot.appendSections([AppConstants.shared.listSectionId])
        snapshot.appendItems(viewModels)
        dataSource.apply(snapshot, animatingDifferences: false)
        offset += models.count
    }
    
    /// update viewmode in datasoruce
    /// - Parameter newModel: Updated model
    override func updated(newModel: GifCellViewModel) {
        super.updated(newModel: newModel)
        var snapshot = dataSource.snapshot()
        print(newModel.id)
        snapshot.reloadItems([newModel])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    /// If viewmodel changed notifiation wil be triggred with updated model
    /// - Parameter notification:notification object
    @objc func reloadDataSource(notification:Notification) {
        print(viewModels.map({$0.id}))
        guard let model = notification.object as? GifCellViewModel, self.viewModels.contains(model) else {
            return
        }
        updated(newModel: model)
    }

    //    MARK: Fetch view model with common viewtype
    
    /// Reset fetch and load from first
    /// - Parameter type: Fetchtype
    private func loadFresh(type:FetchType) {
        offset = 0
        self.fetchType = type
        fetch(type: type, dataSource: self)
    }
    
    /// Fetch more gifs
    /// - Parameter type: Fetchtype
    private func loadMore(type:FetchType) {
        self.fetchType = type
        self.delegate?.setBottomLoader(true)
        fetch(type: type, dataSource: self)
    }
    
    //    MARK: When ever reset fetch type
    
    /// Rest current fetch and fetch again
    @objc func loadCurrentFetchFresh() {
        self.resetOffsetCurrentQurey()
        self.loadFresh(type: fetchType)
    }
    
    
    /// Loading with search stringn
    /// - Parameter string: Search string
    private func loadSearch(with string:String) {
        self.loadFresh(type: .search(qurey: string, offset: 0, limit: AppConstants.shared.limit))
    }
    
    /// Load tread
    private func loadTrend() {
        self.loadFresh(type: .trend(offset: 0, limit: AppConstants.shared.limit))

    }

    
    //    MARK: Utils
    
    /// Reset the fetch param offset to 0
    func resetOffsetCurrentQurey() {
        switch fetchType {
        case .trend(_ , let limit):
            self.fetchType = .trend(offset: 0, limit: limit)
        case .search(let qurey, _ , let limit):
            self.fetchType = .search(qurey:qurey, offset: 0, limit: limit)
        default:
            break
        }
    }
    
  }


//    MARK: Search delegate

extension FeedTableModel:UISearchBarDelegate {

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if (searchBar.text?.isEmpty ?? true) == true{
            self.loadTrend()
        }

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tempTime?.invalidate()
        tempTime = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self](_) in
            if let text = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), text.isEmpty == false{
                self?.loadSearch(with: text)
            }
        })
    }

}

//    MARK: Table delegate

extension FeedTableModel:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView,
      contextMenuConfigurationForRowAt indexPath: IndexPath,
      point: CGPoint) -> UIContextMenuConfiguration? {
        guard var viewModel = dataSource.itemIdentifier(for: indexPath) else {return nil}
        return viewModel.getContextMenuConfig(for: dataSource.tableView(tableView, cellForRowAt: indexPath)) { () -> UIViewController? in
            PreviewController(viewModel: viewModel)
        }
    }
    
}

//    MARK: Scroll delgate to monitor loadmore

extension FeedTableModel {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            //reach bottom
            if !isFetching {
                switch fetchType {
                case .trend(_, let limit):
                    self.loadMore(type: .trend(offset: self.offset, limit: limit))
                    break
                case .search(let qurey, _, let limit):
                    self.loadMore(type: .search(qurey:qurey, offset: self.offset, limit: limit))
                default:
                    break
                }
            }
        }
    }

}

extension FeedTableModel{}




