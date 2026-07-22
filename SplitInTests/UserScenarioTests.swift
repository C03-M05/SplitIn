//
//  UserScenarioTests.swift
//  SplitInTests
//
//  Created by Axel Valent Prayogo on 15/07/26.
//
//  End-to-end test: menguji ALUR USER LENGKAP, bukan fungsi terisolasi.
//  Pakai SwiftData asli (in-memory) supaya CRUD, relationship, cascade
//  delete, dan kalkulasi diuji bekerja sama — persis seperti saat app dipakai.
//
//  Nama fungsi sengaja dibuat deskriptif: baca namanya = tahu skenario apa
//  yang diuji, tanpa harus baca isinya.
//

import XCTest
import SwiftData
@testable import SplitIn

final class UserScenarioTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        let schema = Schema([
            Group.self, Person.self, GroupMember.self,
            Bill.self, BillItem.self, ItemSplit.self, Settlement.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
    }

    override func tearDown() {
        container = nil
        context = nil
    }

    // MARK: - Helper agar tiap test ringkas

    /// Buat grup + member sekaligus, kembalikan grup dan dictionary member by name.
    private func makeGroup(named name: String, members names: [String]) -> (Group, [String: GroupMember]) {
        let group = GroupFactory.createGroup(context: context, name: name, memberNames: names)
        var byName: [String: GroupMember] = [:]
        for member in group.members {
            byName[member.person.name] = member
        }
        return (group, byName)
    }

    /// Buat draft item bagi rata untuk daftar member.
    private func item(_ name: String, price: Decimal, qty: Decimal, for members: [GroupMember]) -> BillItemDraft {
        BillItemDraft(
            name: name,
            price: price,
            quantity: qty,
            participantMemberIDs: members.map(\.id)
        )
    }

    // MARK: - Skenario: bikin grup

    func test_userBuatGrupBaru_grupTersimpanDenganSemuaMember() throws {
        let (group, m) = makeGroup(named: "Malang Trip", members: ["sherin", "miranda", "axel"])
        try context.save()

        XCTAssertEqual(group.name, "Malang Trip")
        XCTAssertEqual(group.members.count, 3)
        XCTAssertNotNil(m["sherin"])
        XCTAssertNotNil(m["miranda"])
        XCTAssertNotNil(m["axel"])
    }

    func test_userGantiNamaGrup_namaBerubah() throws {
        let (group, _) = makeGroup(named: "Trip", members: ["a", "b"])
        GroupFactory.renameGroup(group, to: "Malang Trip")
        try context.save()

        XCTAssertEqual(group.name, "Malang Trip")
    }

    // MARK: - Skenario: bikin bill + kalkulasi utang

    func test_userBuatSatuBill_utangTerhitungBenar() throws {
        let (group, m) = makeGroup(named: "Trip", members: ["sherin", "axel", "farhan"])

        // Sherin bayar Grab 60.000, dibagi rata bertiga.
        try BillFactory.createBill(
            context: context,
            group: group,
            paidBy: m["sherin"]!,
            name: "grab",
            items: [item("Grab", price: 60_000, qty: 1, for: [m["sherin"]!, m["axel"]!, m["farhan"]!])]
        )
        try context.save()

        let sheet = group.balanceSheet()

        // Axel & Farhan masing-masing berutang 20.000 ke Sherin.
        XCTAssertEqual(sheet[m["axel"]!.id]?.payTo.first?.amount, 20_000)
        XCTAssertEqual(sheet[m["farhan"]!.id]?.payTo.first?.amount, 20_000)
        // Sherin menagih dari 2 orang, tidak berutang ke siapa pun.
        XCTAssertEqual(sheet[m["sherin"]!.id]?.collectFrom.count, 2)
        XCTAssertTrue(sheet[m["sherin"]!.id]?.payTo.isEmpty ?? false)
    }

    func test_userBuatDuaBill_utangSalingPotong() throws {
        let (group, m) = makeGroup(named: "Trip", members: ["sherin", "axel"])

        // Bill 1: Sherin bayar 40.000 berdua -> Axel utang 20.000 ke Sherin.
        try BillFactory.createBill(
            context: context, group: group, paidBy: m["sherin"]!, name: "bill1",
            items: [item("x", price: 40_000, qty: 1, for: [m["sherin"]!, m["axel"]!])]
        )
        // Bill 2: Axel bayar 60.000 berdua -> Sherin utang 30.000 ke Axel.
        try BillFactory.createBill(
            context: context, group: group, paidBy: m["axel"]!, name: "bill2",
            items: [item("y", price: 60_000, qty: 1, for: [m["sherin"]!, m["axel"]!])]
        )
        try context.save()

        let sheet = group.balanceSheet()

        // Net: Sherin utang 10.000 ke Axel (30.000 - 20.000).
        XCTAssertEqual(sheet[m["sherin"]!.id]?.payTo.first?.amount, 10_000)
        XCTAssertEqual(sheet[m["sherin"]!.id]?.payTo.first?.counterpartyMemberID, m["axel"]!.id)
        XCTAssertEqual(sheet[m["axel"]!.id]?.collectFrom.first?.amount, 10_000)
    }

    // MARK: - Skenario: edit bill -> utang ikut berubah

    func test_userEditBill_utangIkutBerubah() throws {
        let (group, m) = makeGroup(named: "Trip", members: ["sherin", "axel"])

        let bill = try BillFactory.createBill(
            context: context, group: group, paidBy: m["sherin"]!, name: "bill",
            items: [item("x", price: 40_000, qty: 1, for: [m["sherin"]!, m["axel"]!])]
        )
        try context.save()

        // Sebelum edit: Axel utang 20.000.
        XCTAssertEqual(group.balanceSheet()[m["axel"]!.id]?.payTo.first?.amount, 20_000)

        // User edit: harga naik jadi 100.000.
        try BillFactory.updateBill(
            context: context, bill: bill, name: "bill", paidBy: m["sherin"]!, billDate: nil,
            items: [item("x", price: 100_000, qty: 1, for: [m["sherin"]!, m["axel"]!])],
            totalFinal: nil
        )
        try context.save()

        // Sesudah edit: Axel utang 50.000.
        XCTAssertEqual(group.balanceSheet()[m["axel"]!.id]?.payTo.first?.amount, 50_000)
    }

    // MARK: - Skenario: hapus bill -> utang bersih

    func test_userHapusBill_utangKembaliBersih() throws {
        let (group, m) = makeGroup(named: "Trip", members: ["sherin", "axel"])

        let bill = try BillFactory.createBill(
            context: context, group: group, paidBy: m["sherin"]!, name: "bill",
            items: [item("x", price: 40_000, qty: 1, for: [m["sherin"]!, m["axel"]!])]
        )
        try context.save()

        XCTAssertFalse(group.balanceSheet()[m["axel"]!.id]?.payTo.isEmpty ?? true)

        // User hapus bill.
        BillFactory.deleteBill(context: context, bill: bill, from: group)
        try context.save()

        // Semua utang harus bersih.
        XCTAssertTrue(group.balanceSheet()[m["axel"]!.id]?.payTo.isEmpty ?? false)
        XCTAssertEqual(group.bills.count, 0)
    }

    // MARK: - Skenario: hapus grup -> semua ikut terhapus (cascade)

    func test_userHapusGrup_semuaBillDanMemberIkutTerhapus() throws {
        let (group, m) = makeGroup(named: "Trip", members: ["sherin", "axel"])
        try BillFactory.createBill(
            context: context, group: group, paidBy: m["sherin"]!, name: "bill",
            items: [item("x", price: 40_000, qty: 1, for: [m["sherin"]!, m["axel"]!])]
        )
        try context.save()

        GroupFactory.deleteGroup(group, context: context)
        try context.save()

        let remainingGroups = try context.fetch(FetchDescriptor<Group>())
        let remainingBills = try context.fetch(FetchDescriptor<Bill>())
        XCTAssertEqual(remainingGroups.count, 0)
        XCTAssertEqual(remainingBills.count, 0, "Bill harus ikut terhapus lewat cascade")
    }

    // MARK: - Skenario: item multi-porsi tapi ditag beda jumlah orang

    func test_userTagItemKeEmpatOrang_dibagiRataEmpat() throws {
        // Spec asli: "nasi goreng 3 porsi 20rb dibagi ber-4 orang".
        // Quantity 3 hanya untuk hitung total; pembagian ikut jumlah yang di-tag (4).
        let (group, m) = makeGroup(named: "Trip", members: ["sherin", "miranda", "axel", "farhan"])

        try BillFactory.createBill(
            context: context, group: group, paidBy: m["sherin"]!, name: "makan",
            items: [item("Nasi Goreng", price: 20_000, qty: 3, for: [m["sherin"]!, m["miranda"]!, m["axel"]!, m["farhan"]!])]
        )
        try context.save()

        // Total 60.000 dibagi 4 = 15.000. Sherin (payer) tidak berutang.
        let sheet = group.balanceSheet()
        XCTAssertEqual(sheet[m["miranda"]!.id]?.payTo.first?.amount, 15_000)
        XCTAssertEqual(sheet[m["axel"]!.id]?.payTo.first?.amount, 15_000)
        XCTAssertEqual(sheet[m["farhan"]!.id]?.payTo.first?.amount, 15_000)
    }

    // MARK: - Skenario: diskon

    func test_userInputHargaAkhirLebihMurah_diskonTerdistribusiRata() throws {
        let (group, m) = makeGroup(named: "Trip", members: ["sherin", "axel"])

        // Item 100.000, tapi harga akhir 90.000 -> diskon 10%.
        try BillFactory.createBill(
            context: context, group: group, paidBy: m["sherin"]!, name: "bill",
            items: [item("x", price: 100_000, qty: 1, for: [m["sherin"]!, m["axel"]!])],
            totalFinal: 90_000
        )
        try context.save()

        // Axel: bagian 50.000, setelah diskon 10% = 45.000.
        XCTAssertEqual(group.balanceSheet()[m["axel"]!.id]?.payTo.first?.amount, 45_000)
    }
}
