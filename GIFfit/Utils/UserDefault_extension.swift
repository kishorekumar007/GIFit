//
//  UserDefault_extension.swift
//  GIFfit
//
//  Created by kishore Kumar on 29/10/20.
//

import Foundation

extension UserDefaults {
    var favourites: [String]? {
        set {
            setValue(newValue, forKey: AppConstants.shared.favouritesKey)
        }
        get {
            value(forKey: AppConstants.shared.favouritesKey) as? [String]
        }
    }
}


