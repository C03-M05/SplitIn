//
//  Seeders.swift
//  SplitIn
//
//  Created by Axel Valent Prayogo on 15/07/26.
//
//  Data dummy untuk SwiftUI Preview. Semua dev Fase 1 pakai ini supaya
//  Preview mereka menampilkan data realistis (skenario "Malang Trip" dari
//  design mock) tanpa harus bikin data manual tiap kali.
//
//  Pemakaian di Preview:
//      #Preview {
//          let container = Seeders.previewContainer()
//          SomeView()
//              .modelContainer(container)
//      }
//

import Foundation
import SwiftData

enum Seeders {

    /// Buat ModelContainer in-memory yang sudah terisi skenario "Malang Trip".
    @MainActor
    static func previewContainer() -> ModelContainer {
        let schema = Schema([
            Group.self, Person.self, GroupMember.self,
            Bill.self, BillItem.self, ItemSplit.self, Settlement.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            seedMalangTrip(into: container.mainContext)
            return container
        } catch {
            fatalError("Gagal membuat preview container: \(error)")
        }
    }

    /// Isi context dengan grup "Malang Trip": 5 orang, 2 bill.
    @MainActor
    static func seedMalangTrip(into context: ModelContext) {
        let group = Group(name: "Malang Trip")
        context.insert(group)

        func member(_ name: String) -> GroupMember {
            let person = Person(name: name)
            context.insert(person)
            let m = GroupMember(group: group, person: person)
            context.insert(m)
            group.members.append(m)
            return m
        }

        let sherin = member("sherin")
        let miranda = member("miranda")
        let axel = member("axel")
        let farhan = member("farhan")
        let theo = member("theo")

        // Bill 1: grab to alun-alun — Rp 65.000, dibayar sherin, dibagi sherin+axel+farhan
        let grab = Bill(group: group, paidBy: sherin, name: "grab to alun-alun")
        context.insert(grab)
        let grabItem = BillItem(bill: grab, name: "Grab", price: 65_000, quantity: 1)
        context.insert(grabItem)
        for m in [sherin, axel, farhan] {
            let s = ItemSplit(item: grabItem, member: m)
            context.insert(s)
            grabItem.splits.append(s)
        }
        grab.items.append(grabItem)
        group.bills.append(grab)

        // Bill 2: lunch @tanjungapi — dibayar miranda
        let lunch = Bill(group: group, paidBy: miranda, name: "lunch @tanjungapi")
        context.insert(lunch)

        let ayam = BillItem(bill: lunch, name: "Ayam Goreng Kampung", price: 27_000, quantity: 2)
        context.insert(ayam)
        for m in [sherin, miranda] {
            let s = ItemSplit(item: ayam, member: m)
            context.insert(s)
            ayam.splits.append(s)
        }

        let nasi = BillItem(bill: lunch, name: "Nasi Goreng Cumi", price: 34_000, quantity: 2)
        context.insert(nasi)
        for m in [axel, theo] {
            let s = ItemSplit(item: nasi, member: m)
            context.insert(s)
            nasi.splits.append(s)
        }

        let esteh = BillItem(bill: lunch, name: "Es Teh Manis", price: 7_000, quantity: 5)
        context.insert(esteh)
        for m in [sherin, miranda, farhan, axel, theo] {
            let s = ItemSplit(item: esteh, member: m)
            context.insert(s)
            esteh.splits.append(s)
        }

        lunch.items.append(contentsOf: [ayam, nasi, esteh])
        group.bills.append(lunch)
    }
}
