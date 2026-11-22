import AlarmKit
import Foundation
import Observation
import SwiftUI

/// Coordinador de Fase 1 para validar permisos de AlarmKit, disparo en modo silencio/No Molestar
/// y apertura automática de la app mediante LiveActivityIntent en iPhone 15 (iOS 26+).
@Observable
@MainActor
final class Phase1AlarmCoordinator {
    static let shared = Phase1AlarmCoordinator()

    enum AuthStatus: String {
        case notDetermined = "Sin solicitar"
        case authorized = "Autorizado"
        case denied = "Denegado"
    }

    var authStatus: AuthStatus = .notDetermined
    var scheduledAlarmID: UUID?
    var scheduledFireDate: Date?
    var lastOpenedAlarmLabel: String?
    var lastOpenedAt: Date?
    var statusMessage: String?
    var errorMessage: String?

    private init() {
        refreshAuthorizationState()
    }

    func refreshAuthorizationState() {
        switch AlarmManager.shared.authorizationState {
        case .notDetermined:
            authStatus = .notDetermined
        case .authorized:
            authStatus = .authorized
        case .denied:
            authStatus = .denied
        @unknown default:
            authStatus = .denied
        }
    }

    func requestAuthorization() async {
        errorMessage = nil
        do {
            let state = try await Self.requestAlarmAuthorization()
            switch state {
            case .authorized:
                authStatus = .authorized
                statusMessage = "Permiso concedido. Ya podés programar la alarma de prueba."
            case .denied:
                authStatus = .denied
                errorMessage = "Permiso denegado. Habilitalo en Ajustes > AlarmaMy."
            case .notDetermined:
                authStatus = .notDetermined
            @unknown default:
                authStatus = .denied
            }
        } catch {
            errorMessage = "Error al pedir permiso de AlarmKit: \(error.localizedDescription)"
        }
    }

    func scheduleTestAlarm(inSeconds seconds: TimeInterval = 15) async {
        errorMessage = nil
        statusMessage = nil

        if AlarmManager.shared.authorizationState == .notDetermined {
            await requestAuthorization()
        } else {
            refreshAuthorizationState()
        }

        guard authStatus == .authorized else {
            errorMessage = "Necesitás autorizar AlarmKit para probar la alarma."
            return
        }

        if let existingID = scheduledAlarmID {
            try? AlarmManager.shared.cancel(id: existingID)
        }

        let alarmID = UUID()
        let fireDate = Date().addingTimeInterval(seconds)
        let label = "Prueba AlarmaMy"

        let stopIntent = StartMissionsIntent(alarmID: alarmID, label: label)
        let secondaryIntent = StartMissionsIntent(alarmID: alarmID, label: label)

        let alertPresentation = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: label),
            stopButton: AlarmButton(
                text: "Abrir misiones",
                textColor: .white,
                systemImageName: "bolt.fill"
            ),
            secondaryButton: AlarmButton(
                text: "Iniciar",
                textColor: .white,
                systemImageName: "checkmark.circle.fill"
            ),
            secondaryButtonBehavior: .custom
        )

        let attributes = AlarmAttributes<AlarmaMetadata>(
            presentation: AlarmPresentation(alert: alertPresentation),
            metadata: AlarmaMetadata(label: label, missionCount: 3, isReRingGuard: false),
            tintColor: .orange
        )

        let configuration = AlarmManager.AlarmConfiguration<AlarmaMetadata>.alarm(
            schedule: .fixed(fireDate),
            attributes: attributes,
            stopIntent: stopIntent,
            secondaryIntent: secondaryIntent,
            sound: .default
        )

        do {
            try await Self.scheduleAlarm(id: alarmID, configuration: configuration)
            scheduledAlarmID = alarmID
            scheduledFireDate = fireDate
            lastOpenedAlarmLabel = nil
            lastOpenedAt = nil
            statusMessage = "Alarma programada en \(Int(seconds)) segundos. Bloqueá la pantalla y probá con Modo Silencio activado."
        } catch {
            errorMessage = "No se pudo programar la alarma: \(error.localizedDescription)"
        }
    }

    func cancelTestAlarm() {
        errorMessage = nil
        guard let id = scheduledAlarmID else { return }
        do {
            try AlarmManager.shared.cancel(id: id)
            scheduledAlarmID = nil
            scheduledFireDate = nil
            statusMessage = "Alarma de prueba cancelada."
        } catch {
            errorMessage = "No se pudo cancelar: \(error.localizedDescription)"
        }
    }

    func handleAlarmOpenedFromSystem(alarmID: String, label: String) {
        if let uuid = UUID(uuidString: alarmID) {
            try? AlarmManager.shared.stop(id: uuid)
        }
        scheduledAlarmID = nil
        scheduledFireDate = nil
        lastOpenedAlarmLabel = label
        lastOpenedAt = Date()
        statusMessage = "¡AlarmKit abrió AlarmaMy correctamente! En Fase 3 y 4 acá arrancarán tus misiones."
    }

    nonisolated private static func requestAlarmAuthorization() async throws -> AlarmManager.AuthorizationState {
        try await AlarmManager.shared.requestAuthorization()
    }

    nonisolated private static func scheduleAlarm(
        id: UUID,
        configuration: sending AlarmManager.AlarmConfiguration<AlarmaMetadata>
    ) async throws {
        _ = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
    }
}
