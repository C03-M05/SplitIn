//
//  SplitInWidget.swift
//  SplitInWidget
//
//  Created by ahmadfarhanqf on 28/07/26.
//

import AppIntents
import SwiftUI
import UIKit
import WidgetKit

struct SplitInWidgetEntry: TimelineEntry {
    let date: Date
    let group: SplitInWidgetGroupSnapshot?

    static func preview() -> SplitInWidgetEntry {
        SplitInWidgetEntry(
            date: .now,
            group: SplitInWidgetGroupSnapshot(
                id: UUID(),
                name: "Malang Trip",
                bills: [
                    SplitInWidgetBillSnapshot(
                        id: UUID(),
                        name: "Grab",
                        amount: 65_000,
                        displayAmount: "Rp 65k",
                        billDate: .now
                    ),
                    SplitInWidgetBillSnapshot(
                        id: UUID(),
                        name: "Ayam Goreng",
                        amount: 54_000,
                        displayAmount: "Rp 54k",
                        billDate: .now
                    ),
                    SplitInWidgetBillSnapshot(
                        id: UUID(),
                        name: "Es Teh",
                        amount: 35_000,
                        displayAmount: "Rp 35k",
                        billDate: .now
                    )
                ],
                checklistText: "*[Malang Trip]*"
            )
        )
    }
}

struct SplitInWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SplitInWidgetEntry {
        .preview()
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SplitInWidgetEntry {
        entry(for: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SplitInWidgetEntry> {
        Timeline(
            entries: [entry(for: configuration)],
            policy: .after(Date().addingTimeInterval(15 * 60))
        )
    }

    private func entry(for configuration: ConfigurationAppIntent) -> SplitInWidgetEntry {
        let snapshot = SplitInWidgetStore.loadSnapshot()
        let selectedID = SplitInWidgetStore.selectedGroupID(from: configuration.group?.id)
        return SplitInWidgetEntry(
            date: .now,
            group: snapshot.group(with: selectedID)
        )
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "SplitIn Group"
    static var description = IntentDescription("Choose the group to show in the widget.")

    @Parameter(title: "Group")
    var group: SplitInWidgetGroupEntity?
}

struct SplitInWidgetGroupEntity: AppEntity, Identifiable, Hashable {
    static let placeholderID = "placeholder"
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Group")
    static var defaultQuery = SplitInWidgetGroupQuery()

    let id: String
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct SplitInWidgetGroupQuery: EntityStringQuery {
    func entities(matching string: String) async throws -> [SplitInWidgetGroupEntity] {
        entities().filter { entity in
            entity.name.localizedCaseInsensitiveContains(string)
        }
    }

    func entities(for identifiers: [String]) async throws -> [SplitInWidgetGroupEntity] {
        let allEntities = entities()
        return identifiers.compactMap { identifier in
            allEntities.first { $0.id == identifier }
        }
    }

    func suggestedEntities() async throws -> [SplitInWidgetGroupEntity] {
        entities()
    }

    private func entities() -> [SplitInWidgetGroupEntity] {
        let snapshot = SplitInWidgetStore.loadSnapshot()
        let groups = snapshot.groups.map { group in
            SplitInWidgetGroupEntity(
                id: group.id.uuidString,
                name: group.name
            )
        }

        if groups.isEmpty {
            return [
                SplitInWidgetGroupEntity(
                    id: SplitInWidgetGroupEntity.placeholderID,
                    name: "No groups yet"
                )
            ]
        }

        return groups
    }
}

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

// MARK: - Root View

struct SplitInWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family

    let entry: SplitInWidgetEntry

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                MediumSplitInWidgetView(entry: entry)

            case .systemSmall:
                SmallSplitInWidgetView(entry: entry)

            default:
                SmallSplitInWidgetView(entry: entry)
            }
        }
        .containerBackground(for: .widget) {
            WidgetBackground()
        }
    }
}

// MARK: - Small Widget

private struct SmallSplitInWidgetView: View {
    let entry: SplitInWidgetEntry

    var body: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / 170, proxy.size.height / 170)
            let group = entry.group

            VStack(alignment: .leading, spacing: 9 * scale) {
                Text(group?.name ?? "No Group")
                    .font(.system(size: 27 * scale, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.65)

                Spacer(minLength: 2 * scale)

                Link(destination: addBillURL(for: group?.id)) {
                    WidgetActionCapsule(
                        title: "Add Bill",
                        style: .orange,
                        height: 43 * scale,
                        fontSize: 20 * scale
                    )
                }
                .disabled(group == nil)

                Button(intent: CopyChecklistIntent(groupID: group?.id)) {
                    WidgetActionCapsule(
                        title: "Copy List",
                        style: .grey,
                        height: 42 * scale,
                        fontSize: 20 * scale
                    )
                }
                .buttonStyle(.plain)
                .disabled(group == nil)
            }
            .padding(16 * scale)
        }
    }
}

// MARK: - Medium Widget

private struct MediumSplitInWidgetView: View {
    let entry: SplitInWidgetEntry

    var body: some View {
        GeometryReader { proxy in
            let widthScale = proxy.size.width / 364
            let heightScale = proxy.size.height / 169
            let scale = min(widthScale, heightScale)
            let group = entry.group

            VStack(spacing: 9 * scale) {
                HStack(spacing: 12 * scale) {
                    Text(group?.name ?? "No Group")
                        .font(.system(size: 29 * scale, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Spacer(minLength: 8 * scale)

                    Text(group?.totalDisplayAmount ?? "Rp 0")
                        .font(.system(size: 23 * scale, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                }
                .frame(height: 35 * scale)

                HStack(spacing: 15 * scale) {
                    BillList(bills: group?.bills ?? [], scale: scale)

                    VStack(spacing: 8 * scale) {
                        Link(destination: addBillURL(for: group?.id)) {
                            WidgetActionCapsule(
                                title: "Add Bill",
                                style: .orange,
                                height: 38 * scale,
                                fontSize: 19 * scale
                            )
                        }
                        .disabled(group == nil)

                        Button(intent: CopyChecklistIntent(groupID: group?.id)) {
                            WidgetActionCapsule(
                                title: "Copy List",
                                style: .grey,
                                height: 38 * scale,
                                fontSize: 19 * scale
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(group == nil)
                    }
                    .frame(width: 137 * scale)
                }
                .padding(.horizontal, 12 * scale)
                .padding(.vertical, 8 * scale)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 22 * scale)
                        .fill(Color.black.opacity(0.10))
                        .overlay {
                            RoundedRectangle(cornerRadius: 22 * scale)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        }
                }
            }
            .padding(.horizontal, 14 * scale)
            .padding(.vertical, 13 * scale)
        }
    }
}

private struct BillList: View {
    let bills: [SplitInWidgetBillSnapshot]
    let scale: CGFloat

    var body: some View {
        VStack(spacing: 5 * scale) {
            if bills.isEmpty {
                Text("No bills yet")
                    .font(.system(size: 15 * scale, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(Array(bills.prefix(4))) { bill in
                    HStack(spacing: 8 * scale) {
                        Text(bill.name)
                            .lineLimit(1)

                        Spacer(minLength: 5 * scale)

                        Text(bill.displayAmount)
                            .lineLimit(1)
                    }
                    .font(.system(size: 15 * scale, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.92))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Reusable Components

private func addBillURL(for groupID: UUID?) -> URL {
    var components = URLComponents()
    components.scheme = "splitin"
    components.host = "add-bill"
    if let groupID {
        components.queryItems = [URLQueryItem(name: "groupID", value: groupID.uuidString)]
    }
    return components.url ?? URL(string: "splitin://add-bill")!
}

private struct WidgetBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.17, green: 0.17, blue: 0.18),
                Color(red: 0.06, green: 0.06, blue: 0.07)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

private struct WidgetActionCapsule: View {
    enum Style {
        case orange
        case grey
    }

    let title: String
    let style: Style
    let height: CGFloat
    let fontSize: CGFloat

    private var gradientColours: [Color] {
        switch style {
        case .orange:
            return [
                Color(red: 1.00, green: 0.61, blue: 0.19),
                Color(red: 1.00, green: 0.50, blue: 0.12)
            ]

        case .grey:
            return [
                Color(red: 0.63, green: 0.63, blue: 0.64),
                Color(red: 0.48, green: 0.48, blue: 0.50)
            ]
        }
    }

    private var titleColour: Color {
        style == .orange ? .white.opacity(0.90) : .white
    }

    var body: some View {
        Text(title)
            .font(.system(size: fontSize, weight: .regular))
            .foregroundStyle(titleColour)
            .lineLimit(1)
            .minimumScaleFactor(0.70)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: gradientColours,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        Capsule()
                            .stroke(Color.white.opacity(0.20), lineWidth: 1)
                    }
                    .shadow(
                        color: Color.black.opacity(0.30),
                        radius: 5,
                        x: 0,
                        y: 4
                    )
            }
    }
}

struct SplitInWidget: Widget {
    let kind = SplitInWidgetStore.widgetKind

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: SplitInWidgetProvider()
        ) { entry in
            SplitInWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SplitIn")
        .description("Shows a selected group and its latest bills.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium
        ])
        .contentMarginsDisabled()
    }
}

#Preview("Small", as: .systemSmall) {
    SplitInWidget()
} timeline: {
    SplitInWidgetEntry.preview()
}

#Preview("Medium", as: .systemMedium) {
    SplitInWidget()
} timeline: {
    SplitInWidgetEntry.preview()
}
