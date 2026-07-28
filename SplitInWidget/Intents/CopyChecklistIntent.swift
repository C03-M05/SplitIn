//
//  CopyChecklistIntent.swift
//  SplitInWidget
//

import AppIntents
import Foundation
import UIKit

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
    func perform() async throws -> some IntentResult {
        let selectedID = SplitInWidgetStore.selectedGroupID(from: groupID)
        guard let group = SplitInWidgetStore.loadSnapshot().group(with: selectedID) else {
            return .result()
        }

        UIPasteboard.general.string = group.checklistText
        return .result()
    }
}
