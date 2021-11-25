//
//  ProjectsView.swift
//  bookE
//
//  Created by John on 11/10/21.
//

import SwiftUI

struct ProjectsView: View {

    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext

    @State private var showingSortOrder = false
    @State private var sortOrder = Item.SortOrder.optimized
    @State var sortDescriptor: NSSortDescriptor?

    let showClosedProjects: Bool
    let projects: FetchRequest<Project>

    static let openTag: String? = "Open"
    static let closedTag: String? = "Closed"

    init(showClosedProjects: Bool) {
        self.showClosedProjects = showClosedProjects
        projects = FetchRequest<Project>(entity: Project.entity(), sortDescriptors: [
            NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)
        ], predicate: NSPredicate(format: "closed = %d", showClosedProjects))
    }

   func items(for project: Project) -> [Item] {
    switch sortOrder {
    case .title:
        return project.projectItems.sorted { $0.itemTitle < $1.itemTitle }
    case .creationDate:
        return project.projectItems.sorted { $0.itemCreationDate < $1.itemCreationDate }
    case .optimized:
        return project.projectItemsDefaultSorted
    }
}

    var body: some View {
        NavigationView {
            Group {
                if projects.wrappedValue.count == 0 {
                    Text("There's nothing here right now.")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(projects.wrappedValue) { project in
                            Section(header: ProjectHeaderView(project: project)) {
                                ForEach(items(for: project)) { item in
                                    ItemRowView(project: project, item: item)
                        }
                        .onDelete { offsets in
                            let allItems = project.projectItems

                            for offset in offsets {
                                let item = allItems[offset]
                                dataController.delete(item)
                            }
                            dataController.save()
                        }
                        .actionSheet(isPresented: $showingSortOrder) {
                            ActionSheet(title: Text("Sort items"), message: nil, buttons: [
                                .default(Text("Optimized")) { sortOrder = .optimized },
                                .default(Text("Creation Date")) { sortOrder = .creationDate },
                                .default(Text("Title")) { sortOrder = .title }
                            ])
                        }

                        if showClosedProjects == false {
                            Button {
                                withAnimation {
                                    let item = Item(context: managedObjectContext)
                                    item.project = project
                                    item.creationDate = Date()
                                    dataController.save()
                                }
                            } label: {
                                Label("Add New Item", systemImage: "plus")
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if showClosedProjects == false {
                        Button {
                            withAnimation {
                                let project = Project(context: managedObjectContext)
                                project.closed = false
                                project.creationDate = Date()
                                dataController.save()
                            }
                        } label: {
                            Label("Add Project", systemImage: "plus")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSortOrder.toggle()
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
        }
    }
    .navigationTitle(showClosedProjects ? "Closed Projects" : "Open Projects")
    .listStyle(InsetGroupedListStyle())

    SelectSomethingView()
    .toolbar {
        if showClosedProjects == false {
            Button {
                withAnimation {
                    let project = Project(context: managedObjectContext)
                    project.closed = false
                    project.creationDate = Date()
                    dataController.save()
                }
            } label: {
                    Label("Add Project", systemImage: "plus")
                    }
                }
            }
        }
    }

}

struct ProjectsView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ProjectsView(showClosedProjects: false)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
