import SwiftUI
import SwiftData

/// Écran d'accueil : liste de tous les projets
struct ProjectListView: View {
    @Query(sort: \Project.createdAt, order: .reverse) private var projects: [Project]
    @Environment(\.modelContext) private var modelContext
    @State private var showingCreateProject = false
    @State private var projectToDelete: Project?
    @State private var animateHeart = false

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
                if !projects.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingCreateProject = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .tint(Color.accentPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingCreateProject) {
                CreateProjectView()
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

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "heart.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentPrimary)
                .symbolEffect(.bounce, value: animateHeart)

            Text("À deux, c'est mieux !")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)

            Text("Mariage, voyage, déménagement…\nsuivez vos dépenses ensemble.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingCreateProject = true
            } label: {
                Label("C'est parti !", systemImage: "plus")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.accentPrimary)
            .controlSize(.large)
            .padding(.top, 8)

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
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .onDelete(perform: deleteProjects)
        }
        .scrollContentBackground(.hidden)
        .background(Color.warmBackground)
        .animation(.spring(), value: projects.count)
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
