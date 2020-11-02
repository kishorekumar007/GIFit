//
//  FeedTableCell.swift
//  GIFfit
//
//  Created by kishore Kumar on 28/10/20.
//

import UIKit
import SwiftyGif

class FeedTableCell: UITableViewCell {

    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var imageContainer: UIView!
    
    @IBOutlet weak var favoruiteButton: UIButton!
    
    @IBOutlet weak var badgeBG: UIView!
    
    var gifCellViewModel:GifCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.gifImageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.gifImageView.clear()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if tag == 0 {
            self.gifImageView.clipsToBounds = true
            self.gifImageView.layer.cornerRadius = 4
            
            self.imageContainer.layer.shadowOffset = .init(width: 0, height: 2)
            self.imageContainer.layer.shadowRadius = 3
            self.imageContainer.layer.shadowOpacity = 0.3
            self.imageContainer.layer.shadowColor = UIColor.black.cgColor
            tag = 1
            
            self.badgeBG.layer.cornerRadius = (self.badgeBG.frame.height/2)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setup(viewModel:GifCellViewModel) {
        viewModel.setUpCell(cell: self)
        gifCellViewModel = viewModel
    }
    
    @IBAction func toggleFavouriteFlag(_ sender: UIButton) {
        self.gifCellViewModel?.toggleFavoruiteFlag()
    }
    

}

extension FeedTableCell:CellResuable {
    static var identifier: String {
        return AppConstants.shared.listCellId
    }
}

