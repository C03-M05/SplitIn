
import SwiftUI
import UIKit

struct ReceiptCaptureFlow: View {
    let completion: ([Data]) -> Void
    @State private var capturedImage: UIImage?

    var body: some View {
        if let capturedImage {
            ReceiptCropView(image: capturedImage, retake: {
                self.capturedImage = nil
            }, cancel: {
                completion([])
            }, completion: { data in
                completion([data])
            })
        } else {
            ReceiptManualCamera { image in
                guard let image else { completion([]); return }
                // Render orientation into pixels before mapping crop coordinates.
                let format = UIGraphicsImageRendererFormat()
                format.scale = 1
                let maximumDimension: CGFloat = 3000
                let ratio = min(1, maximumDimension / max(image.size.width, image.size.height))
                let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
                capturedImage = UIGraphicsImageRenderer(size: size, format: format).image { _ in
                    image.draw(in: CGRect(origin: .zero, size: size))
                }
            }
            .ignoresSafeArea()
        }
    }
}

private struct ReceiptManualCamera: UIViewControllerRepresentable {
    let completion: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(completion: completion) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.modalPresentationStyle = .fullScreen
        controller.sourceType = .camera
        controller.showsCameraControls = true
        controller.cameraCaptureMode = .photo
        controller.allowsEditing = false
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let completion: (UIImage?) -> Void
        init(completion: @escaping (UIImage?) -> Void) { self.completion = completion }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completion(nil)
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            completion(info[.originalImage] as? UIImage)
        }
    }
}

private struct ReceiptCropView: View {
    let image: UIImage
    let retake: () -> Void
    let cancel: () -> Void
    let completion: (Data) -> Void

    // Unit coordinates keep the selected region stable through layout changes.
    @State private var crop = CGRect(x: 0, y: 0, width: 1, height: 1)
    @State private var showCropError = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Drag the corners to keep only your receipt.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                GeometryReader { geometry in
                    let scale = min(geometry.size.width / image.size.width,
                                    geometry.size.height / image.size.height)
                    let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                    cropCanvas(size: size)
                        .frame(width: size.width, height: size.height)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                .padding(24)

                HStack {
                    Button("Retake", systemImage: "camera", action: retake)
                    Spacer()
                    Button("Reset", systemImage: "arrow.counterclockwise") {
                        crop = CGRect(x: 0, y: 0, width: 1, height: 1)
                    }
                }
                .padding(.horizontal, 24)
                Button(action: useCrop) {
                    Label("Use Crop", systemImage: "crop")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 24)
                .padding(.bottom)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Crop Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: cancel)
                }
            }
            .tint(.orange)
            .alert("Unable to crop image", isPresented: $showCropError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Adjust the crop or retake the photo.")
            }
        }
    }

    private func cropCanvas(size: CGSize) -> some View {
        let rect = CGRect(x: crop.minX * size.width, y: crop.minY * size.height,
                          width: crop.width * size.width, height: crop.height * size.height)
        return ZStack(alignment: .topLeading) {
            Image(uiImage: image)
                .resizable()
                .frame(width: size.width, height: size.height)
                .accessibilityLabel("Receipt photo")
            Path { path in
                path.addRect(CGRect(origin: .zero, size: size))
                path.addRect(rect)
            }
            .fill(.black.opacity(0.55), style: FillStyle(eoFill: true))
            .allowsHitTesting(false)

            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)
                .allowsHitTesting(false)

            ForEach(CropCorner.allCases) { corner in
                Circle()
                    .fill(.orange)
                    .frame(width: 18, height: 18)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .position(x: corner.isLeft ? rect.minX : rect.maxX,
                              y: corner.isTop ? rect.minY : rect.maxY)
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("receiptCrop"))
                        .onChanged { value in
                            move(corner, to: value.location, in: size)
                        })
                    .accessibilityLabel(corner.label)
                    .accessibilityHint("Adjust to resize the crop")
                    .accessibilityAdjustableAction { direction in
                        let amount: CGFloat = direction == .increment ? 0.02 : -0.02
                        let x = (corner.isLeft ? crop.minX + amount : crop.maxX - amount) * size.width
                        let y = (corner.isTop ? crop.minY + amount : crop.maxY - amount) * size.height
                        move(corner, to: CGPoint(x: x, y: y), in: size)
                    }
            }
        }
        .coordinateSpace(name: "receiptCrop")
    }

    private func move(_ corner: CropCorner, to point: CGPoint, in size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let minimum: CGFloat = 0.08
        let x = min(1, max(0, point.x / size.width))
        let y = min(1, max(0, point.y / size.height))
        let left = corner.isLeft ? min(x, crop.maxX - minimum) : crop.minX
        let right = corner.isLeft ? crop.maxX : max(x, crop.minX + minimum)
        let top = corner.isTop ? min(y, crop.maxY - minimum) : crop.minY
        let bottom = corner.isTop ? crop.maxY : max(y, crop.minY + minimum)
        crop = CGRect(x: left, y: top, width: right - left, height: bottom - top)
    }

    private func useCrop() {
        guard let source = image.cgImage else { showCropError = true; return }
        let bounds = CGRect(x: 0, y: 0, width: source.width, height: source.height)
        let pixels = CGRect(x: crop.minX * bounds.width, y: crop.minY * bounds.height,
                            width: crop.width * bounds.width, height: crop.height * bounds.height)
            .integral.intersection(bounds)
        guard let cropped = source.cropping(to: pixels),
              let data = UIImage(cgImage: cropped).jpegData(compressionQuality: 0.95) else {
            showCropError = true
            return
        }
        completion(data)
    }
}

private enum CropCorner: Int, CaseIterable, Identifiable {
    case topLeft, topRight, bottomLeft, bottomRight
    var id: Int { rawValue }
    var isLeft: Bool { self == .topLeft || self == .bottomLeft }
    var isTop: Bool { self == .topLeft || self == .topRight }
    var label: String {
        switch self {
        case .topLeft: "Top left crop corner"
        case .topRight: "Top right crop corner"
        case .bottomLeft: "Bottom left crop corner"
        case .bottomRight: "Bottom right crop corner"
        }
    }
}
