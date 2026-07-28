//
//  WidgetDeepLink.swift
//  SplitInWidget
//
//  Created by ahmadfarhanqf on 28/07/26.
//

import Foundation

// Membuat deep link untuk membuka CreateBillView pada group tertentu.
func addBillURL(for groupID: UUID?) -> URL {
    var components = URLComponents()
    components.scheme = "splitin"
    components.host = "add-bill"
    if let groupID {
        components.queryItems = [URLQueryItem(name: "groupID", value: groupID.uuidString)]
    }
    return components.url ?? URL(string: "splitin://add-bill")!
}
