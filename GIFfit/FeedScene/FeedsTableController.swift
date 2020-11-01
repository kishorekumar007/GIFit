//
//  SearchGifsController.swift
//  GIFfit
//
//  Created by kishore Kumar on 27/10/20.
//

import UIKit
import SwiftyGif



/// This controller has collection of Gifs. You can search and favourite a Gifs.

class FeedsTableController: UITableViewController {

    var searchBar: UISearchBar?
    var feedTableModel:FeedTableModel?
    var refreshSpinner:UIRefreshControl?
    
    var footerActivity:UIActivityIndicatorView?
        
    //    MARK: View cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(FeedTableCell.nib, forCellReuseIdentifier: FeedTableCell.identifier)

        feedTableModel = FeedTableModel(tableView: tableView, viewDelegate: self)

        refreshSpinner = UIRefreshControl.init(frame: .zero)
        refreshSpinner?.addTarget(feedTableModel, action: #selector(feedTableModel?.loadCurrentFetchFresh), for: .valueChanged)
       
        tableView.refreshControl = refreshSpinner
        
        
        searchBar = .init()
        searchBar?.delegate = feedTableModel
        searchBar?.placeholder = "Search GIFs"
        self.navigationItem.titleView = self.searchBar
        
        footerActivity = .init()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
}

//    MARK: Handler UI notifiacitonn from TableViewListViewModel

extension FeedsTableController: ListUIUpdate {
    func shareSheet(source view: UIView?, data: [Any]) {
        self.openShareSheet(data, popFromView: view ?? self.view)
    }
    
    func setDownloadIndicator(enable: Bool) {
    }
    
    func setRefreshLoader(_ enabled: Bool) {
        if enabled {
            self.refreshSpinner?.beginRefreshing()
        }
        else {
            self.refreshSpinner?.endRefreshing()
        }
    }
    
    func showMessage(title: String, message: String) {
        self.showAlert(title: title, message: message)
    }
    
    func setBottomLoader(_ enabled: Bool) {
        if enabled {
            tableView.tableFooterView = footerActivity
            footerActivity?.startAnimating()
        }
        else {
            tableView.tableFooterView = nil
            footerActivity?.stopAnimating()
        }
    }
    func shareSheet(data: [Any]) {
        self.openShareSheet(data, popFromView: self.view)
    }

}
