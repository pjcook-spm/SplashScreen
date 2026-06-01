import SwiftUI
import PhotosUI

/// Settings UI for selecting splash images and animation configuration.
public struct SplashSettingsView: View {
    @Environment(SplashImageStore.self) private var imageStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var photoSelection: PhotosPickerItem?
    @State private var importErrorMessage: String?
    @State private var isImporting = false
    
    public init() {}
    
    public var body: some View {
        @Bindable var imageStore = imageStore
        NavigationStack {
            List {
                Section {
                    SplashImageRow(
                        title: "No Overlay",
                        image: nil,
                        isSelected: imageStore.selection == .noOverlay
                    ) {
                        imageStore.selection = .noOverlay
                    }
                } footer: {
                    Text("Display the logo as a solid colour, without an overlay image.")
                }
                
                Section("Bundled Images") {
                    ForEach(imageStore.bundledAssetNames, id: \.self) { name in
                        SplashImageRow(
                            title: imageStore.displayName(for: name),
                            image: Image(name),
                            isSelected: imageStore.selection == .asset(name)
                        ) {
                            imageStore.selection = .asset(name)
                        }
                    }
                }
                
                Section("From Photo Library") {
                    if
                        let data = imageStore.customImageData,
                        let uiImage = UIImage(data: data)
                    {
                        SplashImageRow(
                            title: "Custom Image",
                            image: Image(uiImage: uiImage),
                            isSelected: imageStore.selection == .custom
                        ) {
                            imageStore.selection = .custom
                        }
                    }
                    
                    let hasCustomImage = imageStore.customImageData != nil
                    PhotosPicker(
                        selection: $photoSelection,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label(
                            hasCustomImage ? "Replace Photo" : "Choose Photo",
                            systemImage: "photo.on.rectangle"
                        )
                    }
                    .disabled(isImporting)
                    
                    if isImporting {
                        HStack {
                            ProgressView()
                            Text("Importing…")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section("Animation") {
                    Picker("Type", selection: $imageStore.animationType) {
                        ForEach(SplashAnimationType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    
                    Picker("Timing", selection: $imageStore.timingCurve) {
                        ForEach(SplashTimingCurve.allCases) { curve in
                            Text(curve.displayName).tag(curve)
                        }
                    }
                    
                    AnimationSliderRow(
                        title: "Duration",
                        value: $imageStore.animationDuration,
                        range: 0.1...5.0,
                        format: .number.precision(.fractionLength(2)),
                        unit: "s"
                    )
                    
                    AnimationSliderRow(
                        title: "Delay",
                        value: $imageStore.animationDelay,
                        range: 0.0...5.0,
                        format: .number.precision(.fractionLength(2)),
                        unit: "s"
                    )
                    
                    AnimationSliderRow(
                        title: "Final Width Fraction",
                        value: $imageStore.finalWidthFraction,
                        range: 0.1...1.0,
                        format: .number.precision(.fractionLength(2))
                    )
                    
                    AnimationSliderRow(
                        title: "Max Final Width",
                        value: $imageStore.maxFinalWidth,
                        range: 100...800,
                        format: .number.precision(.fractionLength(0)),
                        unit: "pt"
                    )
                    
                    AnimationSliderRow(
                        title: "Start Width Multiplier",
                        value: $imageStore.startWidthMultiplier,
                        range: 1...10,
                        format: .number.precision(.fractionLength(2)),
                        unit: "×"
                    )
                }
                
                Section("Tint Colors") {
                    ColorPicker("Light Mode Tint", selection: $imageStore.lightTintColor, supportsOpacity: true)
                    ColorPicker("Dark Mode Tint", selection: $imageStore.darkTintColor, supportsOpacity: true)
                }
            }
            .navigationTitle("Splash Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task(id: photoSelection) {
                await importSelectedPhoto()
            }
            .alert(
                "Couldn't Import Photo",
                isPresented: Binding(
                    get: { importErrorMessage != nil },
                    set: { if !$0 { importErrorMessage = nil } }
                ),
                presenting: importErrorMessage
            ) { _ in
                Button("OK", role: .cancel) { importErrorMessage = nil }
            } message: { message in
                Text(message)
            }
        }
    }
    
    private func importSelectedPhoto() async {
        guard let item = photoSelection else { return }
        isImporting = true
        defer { isImporting = false }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                try imageStore.setCustomImage(data: data)
            }
        } catch {
            importErrorMessage = error.localizedDescription
        }
        photoSelection = nil
    }
}

private struct SplashImageRow: View {
    let title: String
    let image: Image?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Group {
                    if let image {
                        image
                            .resizable()
                        
                    } else {
                        ZStack {
                            Rectangle()
                                .fill(.quaternary)
                            Image(systemName: "circle.slash")
                                .foregroundStyle(.secondary)
                                .font(.title2)
                        }
                    }
                }
                .frame(width: 64, height: 64)
                .clipShape(.rect(cornerRadius: 8))
                
                Text(title)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tint)
                        .font(.title3)
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct AnimationSliderRow<V: BinaryFloatingPoint>: View where V.Stride: BinaryFloatingPoint {
    let title: String
    @Binding var value: V
    let range: ClosedRange<V>
    let format: FloatingPointFormatStyle<Double>
    var unit: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text(Double(value), format: format)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                if !unit.isEmpty {
                    Text(unit)
                        .foregroundStyle(.secondary)
                }
            }
            Slider(value: $value, in: range)
                .accessibilityLabel(title)
        }
    }
}

#Preview {
    SplashSettingsView()
        .environment(SplashImageStore())
}
