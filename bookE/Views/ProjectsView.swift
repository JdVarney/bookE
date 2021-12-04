//
//  ProjectsView.swift
//  bookE
//
//  Created by John on 11/10/21.
//

import SwiftUI

struct ProjectsView: View {

    @StateObject var viewModel: ViewModel
    @State private var showingSortOrder = false
    @State var sortDescriptor: NSSortDescriptor?

    init(dataController: DataController, showClosedProjects: Bool) {
        let viewModel = ViewModel(dataController: dataController, showClosedProjects: showClosedProjects)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    static let openTag: String? = "Open"
    static let closedTag: String? = "Closed"

    var addProjectToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.showClosedProjects == false {
                Button {
                    withAnimation {
                        viewModel.addProject()
                    }
                } label: {
                    if UIAccessibility.isVoiceOverRunning {
                        Text("Add Project")
                    } else {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
        }
    }

    var sortOrderToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showingSortOrder.toggle()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
    }

    var projectsList: some View {
        List {
            ForEach(viewModel.projects) { project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(viewModel.items(for: project)) { item in
                        ItemRowView(project: project, item: item)
                    }
                    .onDelete { offsets in
                        let allItems = project.projectItems

                        for offset in offsets {
                            let item = allItems[offset]
                            viewModel.dataController.delete(item)
                        }
                        viewModel.dataController.save()
                    }
                    .actionSheet(isPresented: $showingSortOrder) {
                        ActionSheet(title: Text("Sort items"), message: nil, buttons: [
                            .default(Text("Optimized")) { viewModel.sortOrder = .optimized },
                            .default(Text("Creation Date")) { viewModel.sortOrder = .creationDate },
                            .default(Text("Title")) { viewModel.sortOrder = .title }
                        ])
                    }

                    if viewModel.showClosedProjects == false {
                        Button {
                            withAnimation {
                                viewModel.addItem(to: project)
                            }
                        } label: {
                            Label("Add New Item", systemImage: "plus")
                        }
                    }
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.projects.isEmpty {
                    Text("There's nothing here right now")
                        .foregroundColor(.secondary)
                } else {
                    projectsList
                        .toolbar {
                            addProjectToolbarItem
                            sortOrderToolbarItem
                    }
                }
            }
            .navigationTitle(viewModel.showClosedProjects ?
                             "Closed Projects" : "Open Projects")
            SelectSomethingView()
        }
        .listStyle(InsetGroupedListStyle())
        .toolbar {
            if viewModel.showClosedProjects == false {
                Button {
                    withAnimation {
                        let project = Project(context: viewModel.dataController.container.viewContext)
                        project.closed = false
                        project.creationDate = Date()
                        viewModel.dataController.save()
                    }
                } label: {
                    Label("Add Project", systemImage: "plus")
                }
            }
        }
    }
}
