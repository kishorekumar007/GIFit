//
//  ResuableCell.swift
//  GIFfit
//
//  Created by kishore Kumar on 28/10/20.
//

import Foundation
import UIKit

protocol CellResuable {
    /// cell identifier
    static var identifier:String {get}
    /// cell xib name
    static   var nibName:String{ get }
    /// cell bundle
    static   var bundle:Bundle{get}
    
    var gifImageView: UIImageView!{get set}
    
    var favoruiteButton: UIButton!{get set}
    
    var gifCellViewModel:GifCellViewModel? {get set}
}

extension CellResuable where Self:UIView {
    
    /// XIB must be in same bundel or you can override it in your cell class
  static var bundle:Bundle {
    
        return Bundle.init(for: self.classForCoder() )
    }
    
    /// Most of the cell nibname is equal to cell classname if not you can override it in your cell class
  static var nibName:String {
       return String.init(describing: self)
    
    }
    
    /// Based on above input this will be executed if needed you can override it in your cell class
  static var nib:UINib {
       return UINib.init(nibName: nibName , bundle: bundle)
    }

}
