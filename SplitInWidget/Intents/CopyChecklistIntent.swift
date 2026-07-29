//
//  CopyChecklistIntent.swift
//  SplitInWidget
//
//  Created by ahmadfarhanqf on 28/07/26.
//

import AppIntents
import Foundation
import UIKit
import WidgetKit

// Intent interaktif untuk menyalin checklist group tanpa membuka app.
struct CopyChecklistIntent: AppIntent {
    static var title: LocalizedStringResource = "Copy Checklist"
    static var description = IntentDescription("Copies the selected SplitIn checklist without opening the app.")
    static var openAppWhenRun = false

    @Parameter(title: "Group ID")
    var groupID: String

    init() {
        groupID = ""
    }

    init(groupID: UUID?) {
        self.groupID = groupID?.uuidString ?? ""
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let selectedID = SplitInWidgetStore.selectedGroupID(from: groupID)
        guard let group = SplitInWidgetStore.loadSnapshot().group(with: selectedID) else {
            return .result(dialog: "Open SplitIn to sync this widget first.")
        }

        UIPasteboard.general.string = group.checklistText
        WidgetCenter.shared.reloadTimelines(ofKind: SplitInWidgetStore.widgetKind)
        return .result(dialog: "Copied to clipboard")
    }
}
