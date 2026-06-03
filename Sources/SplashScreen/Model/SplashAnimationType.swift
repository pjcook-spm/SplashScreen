import Foundation

/// Identifies the animation style used by the splash screen.
public struct SplashAnimationType: OptionSet, Hashable, Sendable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let scale = SplashAnimationType(rawValue: 1 << 0)
    public static let wipe = SplashAnimationType(rawValue: 1 << 1)
    public static let fadeIn = SplashAnimationType(rawValue: 1 << 2)
    public static let fadeOut = SplashAnimationType(rawValue: 1 << 3)

    public static let allCases: [SplashAnimationType] = [.scale, .wipe, .fadeIn, .fadeOut]

    public var displayName: String {
        let names = Self.allCases.compactMap { type in
            contains(type) ? type.singleTypeName : nil
        }

        if names.isEmpty {
            return "None"
        }

        return names.joined(separator: " + ")
    }

    /// Stable storage key for persisted user defaults.
    public var storageKey: String {
        Self.allCases.compactMap { type in
            contains(type) ? type.singleTypeStorageName : nil
        }
        .joined(separator: ",")
    }

    public init?(storageKey: String) {
        let trimmedStorageKey = storageKey.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedStorageKey.isEmpty {
            self = []
            return
        }

        let tokens = trimmedStorageKey
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        var parsedValue: SplashAnimationType = []
        for token in tokens {
            guard let parsedType = SplashAnimationType(storageToken: token) else {
                return nil
            }

            parsedValue.insert(parsedType)
        }

        self = parsedValue
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let rawValue = try? container.decode(Int.self) {
            self.init(rawValue: rawValue)
            return
        }

        if let stringValue = try? container.decode(String.self),
           let decoded = SplashAnimationType(storageKey: stringValue) {
            self = decoded
            return
        }

        let keys = try container.decode([String].self)
        let storageKey = keys.joined(separator: ",")

        guard let decoded = SplashAnimationType(storageKey: storageKey) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid animation type values.")
        }

        self = decoded
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storageKey)
    }

    private init?(storageToken: String) {
        switch storageToken {
            case "scale": self = .scale
            case "wipe": self = .wipe
            case "fadeIn": self = .fadeIn
            case "fadeOut": self = .fadeOut
            default: return nil
        }
    }

    private var singleTypeStorageName: String {
        switch self {
            case .scale: "scale"
            case .wipe: "wipe"
            case .fadeIn: "fadeIn"
            case .fadeOut: "fadeOut"
            default: ""
        }
    }

    private var singleTypeName: String {
        switch self {
            case .scale: "Scale"
            case .wipe: "Wipe"
            case .fadeIn: "Fade In"
            case .fadeOut: "Fade Out"
            default: ""
        }
    }
}
