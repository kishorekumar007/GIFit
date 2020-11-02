//
//  FavouriteGifCell.swift
//  GIFfit
//
//  Created by kishore Kumar on 31/10/20.
//

import UIKit



class FavouriteGifCell: UICollectionViewCell {
    
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var imageContainer: UIView!
    
    @IBOutlet weak var favoruiteButton: UIButton!
    
    @IBOutlet weak var badgeBG: UIView!
    
    var gifCellViewModel:GifCellViewModel?


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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

    
    func setupCell(for viewModel:GifCellViewModel) {
        viewModel.setUpCell(cell: self)
        gifCellViewModel = viewModel

    }
    
    @IBAction func toggleFavouriteFlag(_ sender: UIButton) {
        self.gifCellViewModel?.toggleFavoruiteFlag()
    }


}

extension FavouriteGifCell:CellResuable {
    static var identifier: String {
        AppConstants.shared.listCellId
    }
    
    
}
