//
//  NetworkMapping.swift
//  TestApp
//
//  Created by Sergey Kononov on 04.03.2021.
//

import Foundation


final class NetworkMapping {
    
    static func mappedObjects<T: EntityMapping>(from networkData: Any?, type: T.Type) throws -> [T] {
        guard let networkData = networkData else {
            NSLog("Mapping error: networkData is nil")
            throw NSError(domain: "network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])
        }
        guard let networkItems = networkData as? [[String: Any]] else {
            NSLog("Mapping error: networkData is not an Array")
            throw NSError(domain: "mapping", code: 0, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])
        }
        
        return networkItems.map { item in
            return T(from: item)
        }
    }
}
