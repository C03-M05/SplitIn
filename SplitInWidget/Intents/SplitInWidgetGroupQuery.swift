//
//  SplitInWidgetGroupQuery.swift
//  SplitInWidget
//
//  Created by ahmadfarhanqf on 28/07/26.
//

import AppIntents

// Query AppIntents untuk mencari dan menyarankan group pada Edit Widget.
struct SplitInWidgetGroupQuery: EntityStringQuery {
    func entities(matching string: String) async throws -> [SplitInWidgetGroupEntity] {
        entities().filter { entity in
            entity.name.localizedCaseInsensitiveContains(string)
        }
    }

    func entities(for identifiers: [String]) async throws -> [SplitInWidgetGroupEntity] {
        let allEntities = entities()
        return identifiers.compactMap { identifier in
            allEntities.first {
                $0.id.caseInsensitiveCompare(identifier) == .orderedSame
            }
        }
    }

    func suggestedEntities() async throws -> [SplitInWidgetGroupEntity] {
        entities()
    }

    func defaultResult() async -> SplitInWidgetGroupEntity? {
        entities().first
    }

    private func entities() -> [SplitInWidgetGroupEntity] {
        let snapshot = SplitInWidgetStore.loadSnapshot()
        let groups = snapshot.groups.map { group in
            SplitInWidgetGroupEntity(
                id: group.id.uuidString,
                name: group.name
            )
        }

        return groups
    }
}
