// NotificationManager.swift
// Gerenciador centralizado de notificações locais

import Foundation
import UserNotifications
import SwiftUI

@Observable
final class NotificationManager {
    
    // MARK: - Singleton
    static let shared = NotificationManager()
    private init() {}
    
    // MARK: - Estado
    var isAuthorized: Bool = false
    var authorizationDenied: Bool = false
    
    // MARK: - Constantes
    private let antecedenciaHoras: TimeInterval = 3600 // 1 hora em segundos
    private let categoryIdentifier = "VISITA_REMINDER"
    
    // MARK: - Autorização
    
    /// Solicita permissão para enviar notificações
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                self?.authorizationDenied = !granted
                
                if granted {
                    self?.registerNotificationCategories()
                }
                
                if let error = error {
                    print("❌ Erro ao solicitar autorização: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Verifica o status atual da autorização
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            self.isAuthorized = settings.authorizationStatus == .authorized
            self.authorizationDenied = settings.authorizationStatus == .denied
        }
    }
    
    // MARK: - Registro de Categorias
    
    private func registerNotificationCategories() {
        let verNoMapaAction = UNNotificationAction(
            identifier: "VER_NO_MAPA",
            title: "Ver no Mapa",
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: categoryIdentifier,
            actions: [verNoMapaAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // MARK: - Agendar Notificação
    
    /// Agenda uma notificação 1 hora antes da visita
    @discardableResult
    func agendarNotificacao(para visita: Visita) -> Bool {
        // Não agendar se não autorizado
        guard isAuthorized else {
            print("⚠️ Notificações não autorizadas")
            return false
        }
        
        // Calcular horário da notificação (1h antes)
        let horarioNotificacao = visita.dataHora.addingTimeInterval(-antecedenciaHoras)
        
        // Não agendar notificações para o passado
        guard horarioNotificacao > Date() else {
            print("⚠️ Horário da notificação já passou para: \(visita.enderecoCompleto)")
            return false
        }
        
        // Cancelar notificação anterior se existir
        cancelarNotificacao(para: visita.id)
        
        // Configurar conteúdo
        let content = UNMutableNotificationContent()
        content.title = "🏠 Visita em 1 hora!"
        content.body = "Você tem uma visita agendada às \(visita.horaFormatada) em \(visita.enderecoCompleto)"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = categoryIdentifier
        content.userInfo = [
            "visitaId": visita.id.uuidString,
            "endereco": visita.enderecoCompleto,
            "mapsURL": visita.mapsURL?.absoluteString ?? ""
        ]
        
        // Configurar trigger por data/hora
        let componentes = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: horarioNotificacao
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: componentes, repeats: false)
        
        // Criar request com ID baseado na visita
        let request = UNNotificationRequest(
            identifier: notificationIdentifier(for: visita.id),
            content: content,
            trigger: trigger
        )
        
        // Agendar
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erro ao agendar notificação: \(error.localizedDescription)")
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy HH:mm"
                print("✅ Notificação agendada para: \(formatter.string(from: horarioNotificacao))")
            }
        }
        
        return true
    }
    
    // MARK: - Cancelar Notificação
    
    /// Cancela a notificação de uma visita específica
    func cancelarNotificacao(para visitaId: UUID) {
        let identifier = notificationIdentifier(for: visitaId)
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
        print("🗑️ Notificação cancelada para visita: \(visitaId.uuidString)")
    }
    
    /// Cancela todas as notificações agendadas
    func cancelarTodasNotificacoes() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ Todas as notificações canceladas")
    }
    
    // MARK: - Consulta
    
    /// Lista todas as notificações pendentes (para debug)
    func listarNotificacoesPendentes() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    
    /// Verifica se uma visita tem notificação agendada
    func temNotificacaoAgendada(para visitaId: UUID) async -> Bool {
        let pendentes = await listarNotificacoesPendentes()
        let identifier = notificationIdentifier(for: visitaId)
        return pendentes.contains { $0.identifier == identifier }
    }
    
    // MARK: - Helpers
    
    private func notificationIdentifier(for visitaId: UUID) -> String {
        return "visita_\(visitaId.uuidString)"
    }
    
    /// Abre as configurações do app para o usuário habilitar notificações
    func abrirConfiguracoes() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
