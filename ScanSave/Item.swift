//
//  Item.swift
//  ScanSave
//
//  Created by code on 2026-05-03.
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
