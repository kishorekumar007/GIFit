//
//  CommonListModel.swift
//  GIFfit
//
//  Created by kishore Kumar on 28/10/20.
//

import Foundation
import UIKit
import Combine

/// If any changes in model use this protocol to update
protocol MasterDataSource {
    /// Update if any model's param changed
    /// - Parameters:
    ///   - model: updatedModel
    func updated(newModel:GifCellViewModel)
    
    /// Before update a model old value
    /// - Parameter model:
    func beforeUpdate(oldModel:GifCellViewModel)
    
    /// Open share sheet
    /// - Parameters:
    ///   - view: soruce view used in iPad as a popover
    ///   - model: for model
    func share(source view:UIView?, model:GifCellViewModel)
}

/// If any UI update must be notified to view class use this protocol
protocol ListUIUpdate:class {
    /// To add load more spiner at footer
    /// - Parameter enabled: show/hide flag
    func setBottomLoader(_ enabled:Bool)
    
    /// If any message needs to be show to the use you can use this callback
    /// - Parameters:
    ///   - title: Title
    ///   - message: message
    func showMessage(title:String, message:String)
    
    
    /// To set refreshcontroller enable/disable
    /// - Parameter enabled: show/hide flag
    func setRefreshLoader(_ enabled:Bool)
    
    /// Open share sheet
    /// - Parameters:
    ///   - view: soruce view
    ///   - data: url array of stored image
    func shareSheet(source view:UIView?, data:[Any])
    
    /// Present download indicator
    /// - Parameter enable: show/hide flag
    func setDownloadIndicator(enable:Bool)
    
    /// Push to preview controller
    /// - Parameter model: gifmodel
    func pushPreviewController(model:GifCellViewModel)
}


/// Common model for all type of list
class CommonListViewModel:NSObject {
    
    weak var delegate:ListUIUpdate?
    var isFetching:Bool = false {
        didSet {
            self.delegate?.setRefreshLoader(isFetching)
        }
    }
    
    /// Init with
    /// - Parameter delegate: viewupdate listener
    init(delegate:ListUIUpdate?) {
        self.delegate = delegate
    }
    
    internal var viewModels:[GifCellViewModel] = []

    
    var cancellable:AnyCancellable?
    
    /// Fetch the gipfy data using
    /// - Parameters:
    ///   - type: FetchType
    ///   - completion: Completion with GipfyModel
    
    func fetch(type:FetchType, dataSource:MasterDataSource) {
        isFetching = true
        cancellable = URLSession.shared.dataTaskPublisher(for: type.fetchURL)
            .map({$0.data})
            .decode(type: GiphyModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .compactMap({ (val) -> [GifData]? in
                if val.meta?.status == 200 {
                    return val.data
                }
                self.notifyView(title: (val.meta?.status?.string ?? "Error"), message:(val.meta?.msg ?? "Unknown Error"))
                return nil
            }).sink { (result) in
                switch result {
                case .failure(let error):
                    self.delegate?.showMessage(title: "Error", message: "\(error.localizedDescription)")
                case .finished:
                    self.isFetching = false
                }
            } receiveValue: { (data) in
                self.isFetching = false
                self.insert(models: data.compactMap({GifCellViewModel.init(gifData: $0, dataSource: dataSource)}))
            }
            
//        URLSession.shared.giphyModel(with: type) { [weak self] (model, resp, error) in
//
//            guard let model = model else {
//                self?.notifyView(title:"Error", message:(error?.localizedDescription ?? "GiphyModel View Model is nill"))
//                self?.isFetching = false
//
//                return
//            }
//
//            if model.meta?.status == 200 {
//
//                if let viewModel = model.data {
//                    DispatchQueue.main.async {
//                        self?.insert(models:viewModel.compactMap({GifCellViewModel.init(gifData: $0, dataSource: dataSource)}))
//                    }
//                }
//
//            }
//            else {
//                self?.notifyView(title: (model.meta?.status?.string ?? "Error"), message:(model.meta?.msg ?? "Unknown Error"))
//            }
//
//            DispatchQueue.main.async {
//                self?.delegate?.setBottomLoader(false)
//                self?.isFetching = false
//            }
//
//        }.resume()
    }
    
    func notifyView(title:String, message:String) {
        DispatchQueue.main.async {
            self.delegate?.showMessage(title: title, message:message)
        }
    }

    //    MARK: MasterDataSource method
    
    /// Insert action
    /// - Parameter models: models to be inserted
    func insert(models: [GifCellViewModel]) {
        var models = models
        models.removeAll(where: {viewModels.contains($0)})
        viewModels.append(contentsOf: models)
    }
    
    /// Update model from ViewModel
    /// - Parameters:
    ///   - newModel: newvalue
    func updated(newModel:GifCellViewModel){
        guard let index = self.viewModels.firstIndex(of: newModel) else
        {return}
        print(self.viewModels[index].isFavourite)
        self.viewModels[index] = newModel
        print(self.viewModels[index].isFavourite)
    }
    
    
    /// Sending notification that this modle is about to change
    /// - Parameter oldModel: oldModel
    func beforeUpdate(oldModel: GifCellViewModel) {
        
    }
    
    
    /// Open share sheet
    /// - Parameters:
    ///   - view: view
    ///   - model: model
    func share(source view: UIView?, model: GifCellViewModel) {
        
        guard let url = FileManager.documentDirURL?.appendingPathComponent("\(model.id).gif") else {
            self.delegate?.showMessage(title: "Error", message: "Couldn't download image! Try again.")
            return
        }
        
        // if image exists
        guard !FileManager.default.fileExists(atPath: url.path) else {
            self.delegate?.shareSheet(source: view, data: [url])
            return
        }
            
        //download from web and stored locally
        func createFile(for model:GifCellViewModel, data:Data?) -> URL? {
                        
            guard let fileData = data else {
                return nil
            }
            
            guard let url = FileManager.documentDirURL?.appendingPathComponent("\(model.id).gif") else {
                return nil
            }
            
            do {
                if FileManager.default.fileExists(atPath: url.absoluteString) {
                    try fileData.write(to: url, options: .atomic)
                }
                else {
                    try fileData.write(to: url, options: .atomic)
                }
                
                return url
            }
            catch {
                return nil
            }
        }
                
        self.cancellable = URLSession.shared.dataTaskPublisher(for: model.url!)
            .map({$0.data})
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { (finish) in
                switch finish {
                case .failure(_):
                    self.notifyView(title: "Error", message: "Couldn't download image! Try again.")
                case .finished:
                    break
                }
            } receiveValue: { (data) in
                guard let fileurl = createFile(for: model, data: data) else {
                    self.notifyView(title: "Error", message: "Couldn't download image! Try again.")
                    return
                }
                DispatchQueue.main.async {
                    self.delegate?.shareSheet(source: view, data: [fileurl])
                }
                
            }


//        URLSession.shared.download(model: model) { [weak self](fileLocation) in
//            DispatchQueue.main.async {
//                self?.delegate?.setDownloadIndicator(enable: false)
//                if fileLocation == nil {
//                    self?.delegate?.showMessage(title: "Error", message: "Couldn't download image! Try again.")
//                }
//                else {
//                    self?.delegate?.shareSheet(source: view, data: [url])
//                }
//            }
//        }?.resume()
    }
    
    
    /// Remove all viewmodel
    func clearData() {
        viewModels.removeAll()
        //override in your subclass if you want
    }

}

extension CommonListViewModel:MasterDataSource{}

