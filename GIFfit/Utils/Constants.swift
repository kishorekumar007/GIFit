//
//  Constants.swift
//  GIFfit
//
//  Created by kishore Kumar on 27/10/20.
//

import Foundation


/// This struct will store constants of this app.
struct AppConstants {
    
    /// Could access this signleton across the app
    static var shared:AppConstants = {
        AppConstants()
    }()
    
    
    /// Gipfy api key
    var api_key: String{
        return "JHSr5VnlRQMuhUljWu9FDVK8YRGnGlkp"
    }
    
    /// Gipfy api key
    var listSectionId:String {
        return "section"
    }
    
    var listCellId:String {
        return "gifCell"
    }
    
    var limit:Int {
        return 15
    }
    
    var favouritesKey:String {
        return "favourite_gif"
    }

    var didUpdateNotification:String {
        return "onChangeModel"
    }

}
