//
//  Widget.swift
//  Widget
//
//  Created by John Varney on 12/6/21.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {

    func loadItems() -> [Item] {
        let dataController = DataController()
        let itemRequest = dataController.fetchRequestForTopItems(count: 1)
        return dataController.results(for: itemRequest)
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), items: [Item.example])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), items: loadItems())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = SimpleEntry(date: Date(), items: loadItems())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    struct SimpleEntry: TimelineEntry {
        let date: Date
        let items: [Item]
    }

    struct WidgetEntryView: View {
        var entry: Provider.Entry

        var body: some View {
            VStack {
                Text("Up next…")
                    .font(.title)

                if let item = entry.items.first {
                    Text(item.itemTitle)
                } else {
                    Text("Nothing!")
                }
            }
        }
    }

    @main
    struct BookEWidget: Widget {
        let kind: String = "Widget"

        var body: some WidgetConfiguration {
            StaticConfiguration(kind: kind, provider: Provider()) { entry in
                WidgetEntryView(entry: entry)
            }
            .configurationDisplayName("My Widget")
            .description("This is an example widget.")
        }
    }

    struct PortfolioWidget_Previews: PreviewProvider {
        static var previews: some View {
            WidgetEntryView(entry: SimpleEntry(date: Date(), items: [Item.example]))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
