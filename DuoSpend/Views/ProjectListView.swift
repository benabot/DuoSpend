import SwiftUI
import SwiftData

/// Écran d'accueil : liste de tous les projets
struct ProjectListView: View {
    @Query(sort: \Project.createdAt, order: .reverse) private var projects: [Project]
    @Environment(\.modelContext) private var modelContext
    @State private var showingCreateProject = false
    @State private var showingPaywall = false
    @State private var projectForQuickExpense: Project?
    @State private var projectToDelete: Project?
    @State private var animateHeart = false

    private let storeManager = StoreManager.shared

    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    emptyStateView
                } else {
                    projectsList
                }
            }
            .navigationTitle("DuoSpend")
            .navigationDestination(for: Project.self) { project in
                ProjectDetailView(project: project)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        DuoLogoView(size: 28)
                        Text("DuoSpend")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.accentPrimary)
                    }
                }
                if !projects.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        plusToolbarItem
                    }
                }
            }
            .sheet(isPresented: $showingCreateProject) {
                CreateProjectView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(item: $projectForQuickExpense) { project in
                AddExpenseView(project: project)
            }
            .alert(
                "Supprimer le projet ?",
                isPresented: Binding(
                    get: { projectToDelete != nil },
                    set: { if !$0 { projectToDelete = nil } }
                ),
                presenting: projectToDelete
            ) { project in
                Button("Supprimer", role: .destructive) {
                    modelContext.delete(project)
                    projectToDelete = nil
                }
                Button("Annuler", role: .cancel) {
                    projectToDelete = nil
                }
            } message: { project in
                Text("Supprimer \(project.name) et toutes ses dépenses ?")
            }
        }
    }

    // MARK: - Plus Toolbar Item

    @ViewBuilder
    private var plusToolbarItem: some View {
        if projects.count == 1 {
            // 1 seul projet → ouvre directement AddExpenseView
            Button {
                projectForQuickExpense = projects.first
            } label: {
                Image(systemName: "plus")
            }
            .tint(Color.accentPrimary)
        } else {
            // 2+ projets → menu contextuel avec sous-menu projet
            Menu {
                Menu {
                    ForEach(projects) { project in
                        Button {
                            projectForQuickExpense = project
                        } label: {
                            Label("\(project.emoji) \(project.name)", systemImage: "folder")
                        }
                    }
                } label: {
                    Label("Ajouter une dépense", systemImage: "plus.circle")
                }
                Button {
                    handleNewProject()
                } label: {
                    Label("Nouveau projet", systemImage: "folder.badge.plus")
                }
            } label: {
                Image(systemName: "plus")
            }
            .tint(Color.accentPrimary)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            DuoLogoView(size: 96, withBackground: true)
                .shadow(color: Color.accentPrimary.opacity(0.3), radius: 16, y: 6)
                .scaleEffect(animateHeart ? 1.0 : 0.7)
                .opacity(animateHeart ? 1.0 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateHeart)

            VStack(spacing: 8) {
                Text("À deux, c'est mieux !")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)

                Text("Mariage, voyage, déménagement…\nsuivez vos dépenses ensemble.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                handleNewProject()
            } label: {
                Label("C'est parti !", systemImage: "plus")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.accentPrimary)
            .controlSize(.large)
            .padding(.top, 4)

            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.warmBackground)
        .onAppear { animateHeart = true }
    }

    // MARK: - Projects List

    private var projectsList: some View {
        List {
            ForEach(projects) { project in
                NavigationLink(value: project) {
                    ProjectCard(project: project)
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .leading) {
                    Button {
                        projectForQuickExpense = project
                    } label: {
                        Label("Dépense", systemImage: "plus.circle.fill")
                    }
                    .tint(Color.accentPrimary)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .onDelete(perform: deleteProjects)

            Button {
                handleNewProject()
            } label: {
                Label("Nouveau projet", systemImage: "folder.badge.plus")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Color.accentPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .scrollContentBackground(.hidden)
        .background(Color.warmBackground)
        .animation(.spring(), value: projects.count)
    }

    private func handleNewProject() {
        if projects.isEmpty || storeManager.isUnlocked {
            showingCreateProject = true
        } else {
            showingPaywall = true
        }
    }

    private func deleteProjects(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        projectToDelete = projects[index]
    }
}

#Preview {
    ProjectListView()
        .modelContainer(SampleData.container)
}
