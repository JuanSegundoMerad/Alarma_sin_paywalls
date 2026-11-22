import AlarmKit
import Foundation

/// Metadatos personalizados que acompañan cada alarma programada en AlarmKit.
nonisolated struct AlarmaMetadata: AlarmMetadata, Codable, Hashable, Sendable {
    let label: String
    let missionCount: Int
    let isReRingGuard: Bool

    init(label: String, missionCount: Int = 1, isReRingGuard: Bool = false) {
        self.label = label
        self.missionCount = missionCount
        self.isReRingGuard = isReRingGuard
    }
}
