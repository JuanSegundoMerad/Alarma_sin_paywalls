import AlarmKit
import AppIntents
import Foundation

/// Intent ejecutado desde la alerta nativa de AlarmKit (pantalla de bloqueo / Dynamic Island)
/// para traer AlarmaMy al primer plano e iniciar o retomar las misiones pendientes.
struct StartMissionsIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Iniciar misiones"
    static let description = IntentDescription(
        "Abre AlarmaMy para completar las misiones pendientes de la alarma."
    )
    static let supportedModes: IntentModes = .foreground(.immediate)

    @Parameter(title: "ID de alarma")
    var alarmID: String

    @Parameter(title: "Etiqueta")
    var label: String

    init() {
        self.alarmID = ""
        self.label = "Alarma"
    }

    init(alarmID: UUID, label: String) {
        self.alarmID = alarmID.uuidString
        self.label = label
    }

    func perform() async throws -> some IntentResult {
        let id = alarmID
        let alarmLabel = label
        await MainActor.run {
            Phase1AlarmCoordinator.shared.handleAlarmOpenedFromSystem(
                alarmID: id,
                label: alarmLabel
            )
        }
        return .result()
    }
}
