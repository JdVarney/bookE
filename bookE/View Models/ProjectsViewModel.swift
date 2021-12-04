//
//  ProjectsViewModel.swift
//  bookE
//
//  Created by John on 12/2/21.
//

import Foundation
import CoreData

extension ProjectsView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController: DataController
        private let projectsController: NSFetchedResultsController<Project>
        @Published var projects = [Project]()
        let showClosedProjects: Bool
        var sortOrder = Item.SortOrder.optimized

        func addItem(to project: Project) {
            let item = Item(context: dataController.container.viewContext)
            item.project = project
            item.creationDate = Date()
            dataController.save()
        }

        func addProject() {
            let project = Project(context: dataController.container.viewContext)
            project.closed = false
            project.creationDate = Date()
            dataController.save()
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

        init(dataController: DataController, showClosedProjects: Bool) {
            self.dataController = dataController
            self.showClosedProjects = showClosedProjects

            let request: NSFetchRequest<Project> = Project.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)]
            request.predicate = NSPredicate(format: "closed = %d", showClosedProjects)

            projectsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()
            projectsController.delegate = self

            do {
                try projectsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch projects")
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newProjects = controller.fetchedObjects as? [Project] {
                projects = newProjects
            }
        }
    }
}
