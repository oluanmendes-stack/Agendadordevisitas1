// ContentView.swift
// Tela principal — espelho fiel do protótipo React

import SwiftUI
import SwiftData

struct ContentView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Visita.dataHora, order: .forward) private var visitas: [Visita]

    @State private var filtro: FiltroVisitas = .todas
    @State private var search: String = ""
    @State private var showForm = false
    @State private var editVisita: Visita? = nil
    @State private var toast: ToastData? = nil
    @State private var notifBanner: Visita? = nil

    private var filtradas: [Visita] {
        visitas
            .filter { v in
                switch filtro {
                case .todas:    return true
                case .hoje:     return v.isHoje
                case .proximas: return !v.isPassado
                case .passadas: return v.isPassado
                }
            }
            .filter { v in
                guard !search.isEmpty else { return true }
                return v.endereco.localizedCaseInsensitiveContains(search)
                    || v.anotacoes.localizedCaseInsensitiveContains(search)
            }
    }

    private var totalHoje: Int { visitas.filter(\.isHoje).count }

    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        if filtradas.isEmpty {
                            emptyState
                        } else {
                            ForEach(filtradas) { visita in
                                VisitaCardView(
                                    visita: visita,
                                    onEdit:   { editVisita = visita },
                                    onDelete: { deletar(visita) },
                                    onMap:    { abrirMapa(visita) },
                                    onNotif:  { toggleNotif(visita) }
                                )
                                .padding(.horizontal, 14)
                            }
                        }
                        Spacer().frame(height: 20)
                    }
                    .padding(.top, 16)
                }

                tabBar
            }

            // Toast
            if let t = toast {
                ToastView(data: t)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(10)
            }

            // Notification banner
            if let v = notifBanner {
                NotifBannerView(visita: v) { notifBanner = nil }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(11)
            }
        }
        .sheet(isPresented: $showForm) {
            VisitaFormView(mode: .nova) { dados in
                salvar(dados: dados, editando: nil)
            }
        }
        .sheet(item: $editVisita) { v in
            VisitaFormView(mode: .editar(v)) { dados in
                salvar(dados: dados, editando: v)
            }
        }
        .onAppear { agendarBannerDemo() }
        .task { await NotificationManager.shared.checkAuthorizationStatus() }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: toast?.id)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: notifBanner?.id)
    }

    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 0) {
            // Status bar mock
            HStack {
                Text("9:41")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.label)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "wifi")
                    Image(systemName: "battery.100")
                }
                .font(.system(size: 13))
                .foregroundStyle(Color.label)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 8)

            // Nav
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Visitas")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.label)
                    Text("\(visitas.count) imóvel\(visitas.count != 1 ? "s" : "") agendado\(visitas.count != 1 ? "s" : "")")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondaryLabel)
                }
                Spacer()
                Button { showForm = true } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.brandBlue, Color(red: 0, green: 0.333, blue: 0.831)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .shadow(color: Color.brandBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)

            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondaryLabel)
                TextField("Buscar por endereço...", text: $search)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.label)
                if !search.isEmpty {
                    Button { search = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.secondaryLabel)
                    }
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 38)
            .background(Color.pillBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 14)
            .padding(.bottom, 10)

            // Filtros
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(FiltroVisitas.allCases, id: \.self) { f in
                        FilterPillView(
                            filtro: f,
                            selected: filtro == f,
                            badge: f == .hoje ? totalHoje : 0
                        ) {
                            withAnimation(.spring(response: 0.25)) { filtro = f }
                        }
                    }
                }
                .padding(.horizontal, 14)
            }
            .padding(.bottom, 14)
        }
        .background(Color.white)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    // MARK: - Tab bar
    private var tabBar: some View {
        HStack {
            ForEach([("house.fill", "Visitas", true), ("calendar", "Agenda", false), ("map", "Mapa", false)], id: \.0) { icon, label, active in
                Spacer()
                VStack(spacing: 3) {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundStyle(active ? Color.brandBlue : Color.secondaryLabel)
                    Text(label)
                        .font(.system(size: 10, weight: active ? .semibold : .regular))
                        .foregroundStyle(active ? Color.brandBlue : Color.secondaryLabel)
                }
                Spacer()
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { Divider() }
    }

    // MARK: - Empty state
    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("🏠").font(.system(size: 48))
            Text(filtro == .hoje ? "Nada para hoje"
                 : filtro == .proximas ? "Sem visitas futuras"
                 : "Nenhuma visita encontrada")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(red: 0.235, green: 0.235, blue: 0.263))
            Text(filtro == .todas
                 ? "Toque em + para agendar sua primeira visita"
                 : "Tente outro filtro ou agende uma nova visita")
                .font(.system(size: 14))
                .foregroundStyle(Color.secondaryLabel)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .padding(.horizontal, 40)
    }

    // MARK: - Actions
    private func salvar(dados: VisitaDados, editando: Visita?) {
        if let v = editando {
            NotificationManager.shared.cancelarNotificacao(para: v.id)
            v.endereco = dados.endereco; v.bairro = dados.bairro; v.cidade = dados.cidade
            v.dataHora = dados.dataHora; v.precoImovel = dados.preco; v.anotacoes = dados.anotacoes
            if dados.notificacao {
                v.notificacaoAgendada = NotificationManager.shared.agendarNotificacao(para: v)
            } else { v.notificacaoAgendada = false }
            showToast("✅ Visita atualizada!")
        } else {
            let nova = Visita(endereco: dados.endereco, bairro: dados.bairro, cidade: dados.cidade,
                              dataHora: dados.dataHora, precoImovel: dados.preco,
                              anotacoes: dados.anotacoes, notificacaoAgendada: dados.notificacao)
            modelContext.insert(nova)
            if dados.notificacao {
                nova.notificacaoAgendada = NotificationManager.shared.agendarNotificacao(para: nova)
            }
            showToast(dados.notificacao ? "✅ Visita agendada! 🔔 Lembrete ativo" : "✅ Visita agendada!")
        }
    }

    private func deletar(_ v: Visita) {
        NotificationManager.shared.cancelarNotificacao(para: v.id)
        modelContext.delete(v)
        showToast("🗑️ Visita removida")
    }

    private func abrirMapa(_ v: Visita) {
        guard let url = v.mapsURL, UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
        showToast("📍 Abrindo Apple Maps...")
    }

    private func toggleNotif(_ v: Visita) {
        if v.notificacaoAgendada {
            NotificationManager.shared.cancelarNotificacao(para: v.id)
            v.notificacaoAgendada = false
            showToast("🔕 Lembrete desativado")
        } else {
            v.notificacaoAgendada = NotificationManager.shared.agendarNotificacao(para: v)
            showToast("🔔 Lembrete ativado para 1h antes!")
        }
    }

    private func showToast(_ msg: String) {
        withAnimation { toast = ToastData(message: msg) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { toast = nil }
        }
    }

    private func agendarBannerDemo() {
        guard let primeira = visitas.first(where: { $0.isHoje && $0.notificacaoAgendada && !$0.isPassado })
        else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { notifBanner = primeira }
        }
    }
}

// MARK: - Supporting types

enum FiltroVisitas: String, CaseIterable {
    case todas = "Todas", hoje = "Hoje", proximas = "Próximas", passadas = "Passadas"
}

struct VisitaDados {
    var endereco: String; var bairro: String; var cidade: String
    var dataHora: Date;   var preco: Double
    var anotacoes: String; var notificacao: Bool
}

struct ToastData: Identifiable, Equatable {
    let id = UUID(); let message: String
}

// MARK: - Filter Pill

struct FilterPillView: View {
    let filtro: FiltroVisitas
    let selected: Bool
    let badge: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(filtro.rawValue)
                    .font(.system(size: 13, weight: selected ? .bold : .medium))

                if badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 10, weight: .heavy))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(selected ? Color.white.opacity(0.3) : Color.brandOrange)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 7)
            .background(selected ? Color.brandBlue : Color.pillBackground)
            .foregroundStyle(selected ? .white : Color(red: 0.388, green: 0.388, blue: 0.400))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Toast

struct ToastView: View {
    let data: ToastData
    var body: some View {
        Text(data.message)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 20).padding(.vertical, 10)
            .background(Color(red: 0.11, green: 0.11, blue: 0.12))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.2), radius: 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 90)
            .allowsHitTesting(false)
    }
}

// MARK: - Notification Banner

struct NotifBannerView: View {
    let visita: Visita
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.brandOrange)
                    .frame(width: 40, height: 40)
                Text("🏠").font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Visitas Imóveis")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.label)
                Text("🏠 Visita em 1 hora!")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.label)
                Text("Às \(visita.horaFormatada) em \(visita.endereco)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondaryLabel)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    Button {
                        if let url = visita.mapsURL { UIApplication.shared.open(url) }
                        onDismiss()
                    } label: {
                        Text("Ver no Mapa")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.brandBlue)
                    }
                    Text("|").foregroundStyle(Color.tertiaryLabel).font(.system(size: 12))
                    Button { onDismiss() } label: {
                        Text("Dispensar")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.secondaryLabel)
                    }
                }
                .padding(.top, 6)
            }
            Spacer()
            Button { onDismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.secondaryLabel)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 8)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
