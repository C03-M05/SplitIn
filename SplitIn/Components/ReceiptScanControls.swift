
import SwiftUI
import PhotosUI
import UIKit
import AVFoundation
import UniformTypeIdentifiers

struct ReceiptScanControls: View {
    let viewModel: CreateBillViewModel
    @Binding var isScanning: Bool
    @State private var photo: PhotosPickerItem?
    @State private var showCamera = false
    @State private var isOpeningCamera = false
    @State private var capturedImages: [Data] = []
    @State private var showFiles = false
    @State private var showPhotoLibrary = false
    @State private var scanTask: Task<Void, Never>?
    @State private var result: ReceiptScanResult?
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        HStack {
            if isScanning {
                ProgressView().accessibilityLabel("Reading receipt")
                Button("Cancel") {
                    scanTask?.cancel()
                    photo = nil
                    isScanning = false
                }
            } else {
                Button {
                    guard !isOpeningCamera else { return }
                    isOpeningCamera = true
                    scanTask = Task { @MainActor in
                        defer { isOpeningCamera = false }
                        await openCamera()
                    }
                } label: {
                    Image(systemName: "camera").frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel("Scan receipt with camera")
                .disabled(isOpeningCamera)

                Menu {
                    Button("Photo Library", systemImage: "photo") {
                        photo = nil
                        showPhotoLibrary = true
                    }
                    Button("Choose Image File", systemImage: "folder") { showFiles = true }
                } label: {
                    Image(systemName: "photo.badge.plus").frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel("Import receipt image")
            }
        }
        .tint(.orange)
        .photosPicker(
            isPresented: $showPhotoLibrary,
            selection: $photo,
            matching: .images,
            preferredItemEncoding: .automatic,
            photoLibrary: .shared()
        )
        .onChange(of: photo) { _, selection in
            guard let selection else { return }
            start {
                guard let data = try await selection.loadTransferable(type: Data.self) else {
                    throw ReceiptScanError.unreadable
                }
                return [data]
            }
        }
        .fileImporter(isPresented: $showFiles, allowedContentTypes: [.image]) { selection in
            switch selection {
            case .success(let url):
                start {
                    let access = url.startAccessingSecurityScopedResource()
                    defer { if access { url.stopAccessingSecurityScopedResource() } }
                    let values = try url.resourceValues(forKeys: [.fileSizeKey])
                    guard (values.fileSize ?? 0) <= 30_000_000 else { throw ReceiptScanError.unreadable }
                    return [try Data(contentsOf: url)]
                }
            case .failure(let error):
                report(error.localizedDescription)
            }
        }
        .fullScreenCover(isPresented: $showCamera, onDismiss: {
            let images = capturedImages
            capturedImages = []
            if !images.isEmpty { start { images } }
        }) {
            ReceiptCaptureFlow { images in
                capturedImages = images
                showCamera = false
            }
            .interactiveDismissDisabled()
        }
        .sheet(item: $result) { scan in
            ReceiptScanReview(result: scan) { receipt in
                viewModel.applyScannedReceipt(receipt)
                result = nil
            }
        }
        .alert("Receipt Scan", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: { Text(errorMessage ?? "") }
        .onDisappear {
            // Presenting a full-screen camera also hides these controls.
            guard !showCamera else { return }
            scanTask?.cancel()
            isScanning = false
        }
    }

    private func start(_ load: @escaping @MainActor () async throws -> [Data]) {
        scanTask?.cancel()
        isScanning = true
        scanTask = Task { @MainActor in
            defer { if !Task.isCancelled { isScanning = false; photo = nil } }
            do {
                let images = try await load()
                guard images.allSatisfy({ $0.count <= 30_000_000 }) else { throw ReceiptScanError.unreadable }
                let scanned = try await ReceiptScanner().scan(images: images)
                try Task.checkCancellation()
                result = scanned
            } catch {
                if !Task.isCancelled { report(error.localizedDescription) }
            }
        }
    }

    private func openCamera() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            report("Camera capture is unavailable on this device. Import a receipt image instead.")
            return
        }
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        let allowed: Bool
        if status == .notDetermined {
            allowed = await requestCameraAccess()
        } else {
            allowed = status == .authorized
        }
        guard !Task.isCancelled else { return }
        if allowed { showCamera = true }
        else { report("Camera access is disabled. Allow camera access for SplitIn in Settings, or import a photo.") }
    }

    private func requestCameraAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    private func report(_ message: String) {
        errorMessage = message
        showError = true
    }
}

private struct ReceiptScanReview: View {
    @Environment(\.dismiss) private var dismiss
    let result: ReceiptScanResult
    let apply: (ScannedReceipt) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(result.message)
                    if result.receipt != nil {
                        Text("Apply replaces the bill name, items and final total. Existing item assignments will be cleared.")
                    }
                }
                if let receipt = result.receipt {
                    Section("Extracted Bill") {
                        Text(receipt.merchant ?? "Bill name not found")
                        Text(receipt.date ?? "Date not found")
                        Text("Final total: \(receipt.total.map { "Rp \($0)" } ?? "Not found")")
                        ForEach(Array(receipt.items.enumerated()), id: \.offset) { _, item in
                            VStack(alignment: .leading) {
                                Text(item.name)
                                Text("Quantity: \(item.quantity.map(String.init) ?? "?") · Unit price: \(item.unitPrice.map(String.init) ?? "?")")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                Section("Recognized Text") {
                    Text(result.text).textSelection(.enabled)
                }
            }
            .navigationTitle("Review Receipt")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if let receipt = result.receipt, !receipt.items.isEmpty {
                        Button("Apply") { apply(receipt) }
                    }
                }
            }
        }
    }
}
