// VisitaCardView.swift
// Card visual — espelho fiel do protótipo React

import SwiftUI

struct VisitaCardView: View {

    let visita: Visita
    let onEdit:   () -> Void
    let onDelete: () -> Void
    let onMap:    () -> Void
    let onNotif:  () -> Void

    @State private var isPressed = false

    // MARK: - Visual tokens
    private var cardBg: LinearGradient {
        if visita.isHoje {
            return LinearGradient(
                colors: [Color(red: 1, green: 0.969, blue: 0.941), Color(red: 1, green: 0.953, blue: 0.910)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
        if visita.isPassado {
            return LinearGradient(colors: [Color(red: 0.976, green: 0.976, blue: 0.976)], startPoint: .top, endPoint: .bottom)
        }
        return LinearGradient(colors: [.white], startPoint: .top, endPoint: .bottom)
    }

    private var borderColor: Color {
        visita.isHoje ? Color.brandOrange.opacity(0.35) : Color(red: 0.922, green: 0.922, blue: 0.922)
    }

    private var iconBg: Color {
        if visita.isHoje   { return Color.brandOrange.opacity(0.15) }
        if visita.isPassado { return Color.black.opacity(0.06) }
        return Color.brandBlue.opacity(0.10)
    }

    private var iconColor: Color {
        if visita.isHoje    { return .brandOrange }
        if visita.isPassado { return .secondaryLabel }
        return .brandBlue
    }

    private var iconName: String {
        visita.isPassado ? "checkmark" : visita.isHoje ? "star.fill" : "house.fill"
    }

    private var infoColor: Color { visita.isPassado ? .secondaryLabel : .label }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ─────────────────────────────────────
            HStack(alignment: .top, spacing: 12) {

                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconBg)
                        .frame(width: 44, height: 44)
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(iconColor)
                }

                // Texts
                VStack(alignment: .leading, spacing: 4) {
                    Text(visita.endereco)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(visita.isPassado ? Color.secondaryLabel : Color.label)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    let sub = [visita.bairro, visita.cidade].filter { !$0.isEmpty }.joined(separator: " · ")
                    if !sub.isEmpty {
                        Text(sub)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.secondaryLabel)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Badge HOJE
                if visita.isHoje {
                    Text("HOJE")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(0.5)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.brandOrange)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // ── Divider ────────────────────────────────────
            Divider()
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

            // ── Info row ───────────────────────────────────
            HStack(spacing: 16) {
                // Data
                HStack(spacing: 5) {
                    Image(systemName: "calendar")
                        .font(.system(size: 13))
                        .foregroundStyle(iconColor)
                    Text(visita.dataFormatada)
                        .font(.system(size: 13))
                        .foregroundStyle(infoColor)
                }

                // Hora
                HStack(spacing: 5) {
                    Text("⏰").font(.system(size: 13))
                    Text(visita.horaFormatada)
                        .font(.system(size: 13))
                        .foregroundStyle(infoColor)
                }

                Spacer()

                // Preço
                Text(visita.precoFormatado)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.brandGreen)
            }
            .padding(.horizontal, 16)

            // ── Anotações ──────────────────────────────────
            if !visita.anotacoes.isEmpty {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "note.text")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondaryLabel)
                        .padding(.top, 1)
                    Text(visita.anotacoes)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(red: 0.388, green: 0.388, blue: 0.400))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }

            // ── Actions ────────────────────────────────────
            HStack(spacing: 8) {

                // Ver no Mapa
                Button(action: onMap) {
                    HStack(spacing: 6) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 13))
                        Text("Ver no Mapa")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.brandBlue.opacity(0.08))
                    .foregroundStyle(Color.brandBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)

                // Notificação
                if !visita.isPassado {
                    Button(action: onNotif) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 14))
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(
                                visita.notificacaoAgendada
                                    ? Color.brandOrange.opacity(0.10)
                                    : Color.black.opacity(0.04)
                            )
                            .foregroundStyle(
                                visita.notificacaoAgendada ? Color.brandOrange : Color.secondaryLabel
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }

                // Editar
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Color.black.opacity(0.04))
                        .foregroundStyle(Color(red: 0.388, green: 0.388, blue: 0.400))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)

                // Deletar
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Color.brandRed.opacity(0.08))
                        .foregroundStyle(Color.brandRed)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        // Card container
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(borderColor, lineWidth: visita.isHoje ? 1.5 : 1)
        )
        .shadow(
            color: visita.isHoje ? Color.brandOrange.opacity(0.10) : Color.black.opacity(0.05),
            radius: visita.isHoje ? 8 : 4, x: 0, y: 2
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2), value: isPressed)
        ._onButtonGesture(pressing: { isPressed = $0 }, perform: {})
    }
}
