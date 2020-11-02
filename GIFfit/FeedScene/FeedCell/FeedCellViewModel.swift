//
//  ViewModel.swift
//  GIFfit
//
//  Created by kishore Kumar on 27/10/20.
//

import Foundation
import SwiftyGif

let gifManager = SwiftyGifManager.init(memoryLimit: 10)



struct GifCellViewModel:Hashable {
    
    static func == (lhs: GifCellViewModel, rhs: GifCellViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(gifData.id)
    }
    
    private var gifData:GifData
    
    var masterDatasource:MasterDataSource?
    
    var id:String {
        return gifData.id ?? ""
    }
    
    var imageData: The480_WStill?{
        gifData.images?.downsizedMedium
    }
    
    var size: CGSize?{
        guard let height = imageData?.height, let width = imageData?.width, let ht = Int(height), let wd = Int(width) else {
            return nil
        }
        return CGSize(width: wd, height: ht)
    }

    
    var favouriteText:String {
        return isFavourite ? "Mark as Unfavourite" : "Mark as Favourite"
    }
    
    var favouriteImage:UIImage?{
        UIImage(systemName: "star")
    }
    
    var unFavouriteImage:UIImage? {
        UIImage(systemName: "star.fill")
    }
    
    var isFavourite:Bool
    
    var url:URL? {
        guard let urlString = imageData?.url else {
            return nil
        }
        return URL.init(string: urlString)
    }
    
    init?(gifData:GifData?, dataSource:MasterDataSource? = nil){
        guard let data = gifData else {
            return nil
        }
        self.gifData = data
        self.masterDatasource = dataSource
        self.isFavourite = data.isFavourite
    }
    
    var description:String? {
        return gifData.id
    }
    
    mutating func getContextMenuConfig(for cell: UIView, previewProvider: UIContextMenuContentPreviewProvider?)->UIContextMenuConfiguration
    {
        
        let favorite = UIAction(title: favouriteText,
                                image: (!isFavourite ? unFavouriteImage:favouriteImage))
        {_ in
            
            if let feedcell = cell as? CellResuable {
                feedcell.gifCellViewModel?.toggleFavoruiteFlag()
            }
        }
        
        let share = UIAction(title: "Share",
                                image: UIImage(systemName: "square.and.arrow.up")!)
        {_ in
            
            if let feedcell = cell as? CellResuable, let model = feedcell.gifCellViewModel {
                feedcell.gifCellViewModel?.masterDatasource?.share(source: cell, model: model)
            }
        }

        return UIContextMenuConfiguration.init(identifier: NSString.init(string: id), previewProvider: previewProvider) { (_) -> UIMenu? in
            UIMenu(title:"Action", children: [favorite,share])
        }

    }
    
    func setUpCell(cell:CellResuable) {
        cell.favoruiteButton.setImage((isFavourite ? unFavouriteImage:favouriteImage), for: .normal)
        guard let url = url else {
            return
        }
        cell.gifImageView.setGifFromURL(url, manager: gifManager)
    }
    
    func toggleFavoruiteFlag() {
        var changed = self
        self.masterDatasource?.beforeUpdate(oldModel: changed)
        changed.isFavourite = !self.gifData.isFavourite
        changed.gifData.isFavourite = changed.isFavourite
        self.masterDatasource?.updated(newModel: changed)
    }
    
    
}


