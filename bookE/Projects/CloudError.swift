//
//  CloudError.swift
//  bookE
//
//  Created by John Varney on 12/21/21.
//

struct CloudError: Identifiable, ExpressibleByStringInterpolation {
    var id: String { message }
    var message: String

    init(stringLiteral value: String) {
        self.message = value
    }
}
