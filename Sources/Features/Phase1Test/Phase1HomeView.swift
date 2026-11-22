import SwiftUI

struct Phase1HomeView: View {
    @Bindable var coordinator: Phase1AlarmCoordinator

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerCard
                    permissionCard
                    testAlarmCard

                    if let openedLabel = coordinator.lastOpenedAlarmLabel,
                       let openedAt = coordinator.lastOpenedAt {
                        intentSuccessCard(label: openedLabel, openedAt: openedAt)
                    }

                    if let status = coordinator.statusMessage {
                        infoBanner(text: status, color: .blue, icon: "info.circle.fill")
                    }

                    if let error = coordinator.errorMessage {
                        infoBanner(text: error, color: .red, icon: "exclamationmark.triangle.fill")
                    }

                    checklistCard
                }
                .padding()
            }
            .navigationTitle("AlarmaMy")
            .onAppear {
                coordinator.refreshAuthorizationState()
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "alarm.waves.left.and.right.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text("Fase 1 — Prueba de AlarmKit")
                    .font(.headline)
            }
            Text("Verificá que la alarma suene en tu iPhone 15 incluso con Modo Silencio y No Molestar activados, y que al tocar el botón abra AlarmaMy automáticamente.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var permissionCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Permiso de AlarmKit")
                    .font(.subheadline.weight(.semibold))
                Text(coordinator.authStatus.rawValue)
                    .font(.caption)
                    .foregroundStyle(statusColor)
            }

            Spacer()

            if coordinator.authStatus != .authorized {
                Button("Autorizar") {
                    Task {
                        await coordinator.requestAuthorization()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            } else {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var testAlarmCard: some View {
        VStack(spacing: 14) {
            if let fireDate = coordinator.scheduledFireDate, fireDate > Date() {
                VStack(spacing: 6) {
                    Text("Suena en")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(fireDate, style: .timer)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.orange)
                }
                .padding(.vertical, 6)
            }

            Button {
                Task {
                    await coordinator.scheduleTestAlarm(inSeconds: 15)
                }
            } label: {
                Label("Probar alarma en 15 segundos", systemImage: "bell.badge.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)

            if coordinator.scheduledAlarmID != nil {
                Button(role: .destructive) {
                    coordinator.cancelTestAlarm()
                } label: {
                    Label("Cancelar alarma de prueba", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func intentSuccessCard(label: String, openedAt: Date) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("¡Conexión AlarmKit → App verificada!")
                    .font(.headline)
            }
            Text("Alarma: \(label) • Abierta a las \(openedAt.formatted(date: .omitted, time: .standard))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.green.opacity(0.16), in: RoundedRectangle(cornerRadius: 16))
    }

    private func infoBanner(text: String, color: Color, icon: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(text)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
    }

    private var checklistCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cómo probar esta Fase 1")
                .font(.subheadline.weight(.semibold))
            Text("1. Tocá Autorizar si todavía no diste permiso.\n2. Tocá «Probar alarma en 15 segundos».\n3. Activá Modo Silencio y bloqueá el iPhone.\n4. Cuando suene, tocá «Abrir misiones» y verificá que aparezca el cartel verde arriba.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var statusColor: Color {
        switch coordinator.authStatus {
        case .authorized: .green
        case .denied: .red
        case .notDetermined: .orange
        }
    }
}
