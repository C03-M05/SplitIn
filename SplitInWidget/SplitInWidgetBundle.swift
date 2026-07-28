//
//  SplitInWidgetBundle.swift
//  SplitInWidget
//
//  Created by ahmadfarhanqf on 28/07/26.
//

import WidgetKit
import SwiftUI

@main
// Entry point extension yang mendaftarkan semua widget SplitIn ke WidgetKit.
struct SplitInWidgetBundle: WidgetBundle {
    var body: some Widget {
        SplitInWidget()
    }
}
