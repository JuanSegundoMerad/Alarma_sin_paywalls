import Foundation
import Testing
@testable import AlarmaMy

struct AlarmaMetadataTests {
    @Test func metadataEncodesAndDecodesCleanly() throws {
        let original = AlarmaMetadata(
            label: "Despertar",
            missionCount: 4,
            isReRingGuard: true
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AlarmaMetadata.self, from: data)

        #expect(decoded == original)
        #expect(decoded.missionCount == 4)
        #expect(decoded.isReRingGuard == true)
    }
}
