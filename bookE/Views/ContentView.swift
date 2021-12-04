//
//  ContentView.swift
//  bookE
//
//  Created by John on 11/10/21.
//

import SwiftUI
import CoreSpotlight

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    @SceneStorage("selectedView") var selectedView: String?

    func moveToHome(_ input: Any) {
        selectedView = HomeView.tag
    }
    var body: some View {
        TabView(selection: $selectedView) {

            HomeView(dataController: dataController)
                .tag(HomeView.tag)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            ProjectsView(dataController: dataController, showClosedProjects: false)
                .tag(ProjectsView.openTag)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Open")
                }

            ProjectsView(dataController: dataController, showClosedProjects: true)
                .tag(ProjectsView.closedTag)
                .tabItem {
                    Image(systemName: "checkmark")
                    Text("Closed")
                }

            AwardsView()
                .tag(AwardsView.tag)
                .tabItem {
                    Image(systemName: "rosette")
                    Text("Awards")
                }
        }.onContinueUserActivity(CSSearchableItemActionType, perform: moveToHome)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
