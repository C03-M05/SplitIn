//
//  SplitRepresentable.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 14/07/26.
//

import Foundation

protocol SplitRepresentable{
    var memberID: UUID { get }
    var shares: Decimal { get }
}
