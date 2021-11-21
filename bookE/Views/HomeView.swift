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
                            
                            ForEach(projects) { project in
                                VStack(alignment: .leading) {
                                    Text("\(project.projectItems.count) items")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text(project.projectTitle)
                                        .font(.title2)

                                    ProgressView(value: project.completionAmount)
                                        .accentColor(Color(project.projectColor))
                                }
                                .padding()
                                .background(Color.secondarySystemGroupedBackground)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.2), radius: 5)
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        
                    }
                    VStack(alignment: .leading) {
                        ItemListView(title: "Up next", items: items.wrappedValue.prefix(3))
                        ItemListView(title: "More to explore", items: items.wrappedValue.dropFirst(3))
                    }
                }
            } .toolbar {
                Button("Add Data") {
                    dataController.deleteAll()
                    try? dataController.createSampleData()
                }
            }
            .padding(.horizontal)
            .padding([.horizontal, .top])
            .navigationTitle("Home")
            .background(Color.systemGroupedBackground.ignoresSafeArea(.all))

        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
