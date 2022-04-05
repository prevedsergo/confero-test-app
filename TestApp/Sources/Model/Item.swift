//
//  Item.swift
//  TestApp
//
//  Created by Sergey Kononov on 05/04/2022.
//

import Foundation

// MARK: - EntityMapping protocol

protocol EntityMapping {
    init(from dict: [String: Any])
}

struct Item: EntityMapping {
    let text: String
    
    init(from dict: [String: Any]) {
        text = dict["product_description"] as? String ?? ""
    }
}
