//
//  Foundation_extension.swift
//  GIFfit
//
//  Created by kishore Kumar on 28/10/20.
//

import Foundation
public protocol CommonIntUtility {
    var string:String {get}
}

public extension CommonIntUtility where Self:SignedInteger {
    var string:String {
        return "\(self)"
        
    }
}

extension Int:CommonIntUtility {

}

//extension Int32:CommonIntUtility {
//
//}
//extension Int64:CommonIntUtility{
//}
//
//extension Int16:CommonIntUtility {
//}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}



extension FileManager {
    static var documentDirURL:URL? {
        guard let urlString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        return URL(fileURLWithPath: urlString)
    }
}


