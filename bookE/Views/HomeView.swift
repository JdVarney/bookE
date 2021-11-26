//
//  HomeView.swift
//  bookE
//
//  Created by John on 11/8/21.
//

import SwiftUI
import CoreData

struct HomeView: View {

    @EnvironmentObject var dataController: DataController

    static let tag: String? = "Home"

    let items: FetchRequest<Item>

    // Construct a fetch request to show the 10 highest-priority,
    //      incomplete items from open projects.
    init() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let completedPredicate = NSPredicate(format: "completed = false")
        let openPredicate = NSPredicate(format: "project.closed = false")
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates:
            [completedPredicate, openPredicate])

        request.predicate = compoundPredicate

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Item.priority, ascending: false)
        ]

        request.fetchLimit = 10
        items = FetchRequest(fetchRequest: request)
    }

    var projectRows: [GridItem] {
        [GridItem(.fixed(100))]
    }

    @FetchRequest(entity: Project.entity(), sortDescriptors:
        [NSSortDescriptor(keyPath: \Project.title, ascending: true)],
            predicate: NSPredicate(format: "closed = false"))

    var projects: FetchedResults<Project>

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: projectRows) {
                            ForEach(projects, content: ProjectSummaryView.init)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                VStack(alignment: .leading) {
                    ItemListView(title: "Up next", items: items.wrappedValue.prefix(3))
                    ItemListView(title: "More to explore", items: items.wrappedValue.dropFirst(3))
                }
            }
            .navigationTitle("Home")
            .padding(.horizontal)
            .padding([.horizontal, .top])
            .background(Color.systemGroupedBackground.ignoresSafeArea(.all))
#if DEBUG
            .toolbar {
                Button("Add Data") {
                    dataController.deleteAll()
                    try? dataController.createSampleData()
                }
            }
#endif
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
