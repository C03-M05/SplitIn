//
//  Item.swift
//  SplitIn
//
//  Created by ahmadfarhanqf on 13/07/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
