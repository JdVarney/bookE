//
//  HomeView.swift
//  bookE
//
//  Created by John on 11/8/21.
//

import SwiftUI
import CoreData
import CoreSpotlight

struct HomeView: View {

    @StateObject var viewModel: ViewModel

    static let tag: String? = "Home"

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var projectRows: [GridItem] {
        [GridItem(.fixed(100))]
    }

    var body: some View {
        NavigationView {
             ScrollView {
                 if let item = viewModel.selectedItem {
                     NavigationLink(
                        destination: EditItemView(item: item),
                        tag: item,
                        selection: $viewModel.selectedItem,
                        label: EmptyView.init
                     )
                         .id(item)
                 }
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: projectRows) {
                            ForEach(viewModel.projects, content: ProjectSummaryView.init)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                VStack(alignment: .leading) {
                    ItemListView(title: "Up next", items:
                                    $viewModel.upNext)
                    ItemListView(title: "More to explore", items: $viewModel.moreToExplore)
                }
            }
            .navigationTitle("Home")
            .padding(.horizontal)
            .padding([.horizontal, .top])
            .background(Color.systemGroupedBackground.ignoresSafeArea(.all))
#if DEBUG
            .toolbar {
                Button("Add Data", action: viewModel.addSampleData)
            }
#endif
        }
    }

    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            viewModel.selectItem(with: uniqueIdentifier)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(dataController: .preview)
    }
}
