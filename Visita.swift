// Visita.swift
// Model SwiftData para persistência local

import Foundation
import SwiftData

@Model
final class Visita {
    
    // MARK: - Propriedades persistidas
    var id: UUID
    var endereco: String
    var bairro: String
    var cidade: String
    var dataHora: Date
    var precoImovel: Double
    var anotacoes: String
    var notificacaoAgendada: Bool
    
    // MARK: - Inicializador
    init(
        id: UUID = UUID(),
        endereco: String,
        bairro: String = "",
        cidade: String = "",
        dataHora: Date,
        precoImovel: Double,
        anotacoes: String = "",
        notificacaoAgendada: Bool = false
    ) {
        self.id = id
        self.endereco = endereco
        self.bairro = bairro
        self.cidade = cidade
        self.dataHora = dataHora
        self.precoImovel = precoImovel
        self.anotacoes = anotacoes
        self.notificacaoAgendada = notificacaoAgendada
    }
    
    // MARK: - Computed properties
    
    /// Endereço completo formatado
    var enderecoCompleto: String {
        var partes = [endereco]
        if !bairro.isEmpty { partes.append(bairro) }
        if !cidade.isEmpty { partes.append(cidade) }
        return partes.joined(separator: ", ")
    }
    
    /// Verifica se a visita é hoje
    var isHoje: Bool {
        Calendar.current.isDateInToday(dataHora)
    }
    
    /// Verifica se a visita já passou
    var isPassado: Bool {
        dataHora < Date()
    }
    
    /// Preço formatado em BRL
    var precoFormatado: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: precoImovel)) ?? "R$ 0,00"
    }
    
    /// Data formatada para exibição
    var dataFormatada: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: dataHora)
    }
    
    /// Hora formatada para exibição
    var horaFormatada: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: dataHora)
    }
    
    /// Data e hora completa formatada
    var dataHoraFormatada: String {
        "\(dataFormatada) às \(horaFormatada)"
    }
    
    /// URL para Apple Maps
    var mapsURL: URL? {
        let query = enderecoCompleto.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "maps://?q=\(query)")
    }
}
