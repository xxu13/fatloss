//
//  Item.swift
//  fatloss
//
//  Created by 郑楚舰 on 2026/3/28.
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
