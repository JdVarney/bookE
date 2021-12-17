//
//  Widget.swift
//  Widget
//
//  Created by John Varney on 12/6/21.
//
import SwiftUI
import WidgetKit

    @main
    // swiftlint:disable type_name
    struct bookEWidgets: WidgetBundle {

            var body: some Widget {
                SimpleWidget()
                ComplexWidget()
            }
        }

    struct SimpleWidget_Previews: PreviewProvider {
        static var previews: some View {
            WidgetEntryView(entry: SimpleEntry(date: Date(), items: [Item.example]))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
