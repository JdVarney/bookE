//
//  Error-CloudKitMessages.swift
//  bookE
//
//  Created by John Varney on 12/21/21.
//

import CloudKit
import Foundation

extension Error {
    func getCloudKitError() -> CloudError {
        guard let error = self as? CKError else {
            return "An unknown error occurred: \(self.localizedDescription)"
        }
        switch error.code {
        case .quotaExceeded:
            return "You've exceeded your iCloud quota; please clear up some space then try again."

        case .requestRateLimited:
            return "You've hit iCloud's rate limit; please wait a moment then try again."
        case .notAuthenticated:
            return "There was a problem with your iCloud account; please check that you're logged in to iCloud."
        case .networkFailure, .networkUnavailable, .serverResponseLost, .serviceUnavailable:
            return "There was a problem communicating with iCloud; please check your network connection and try again."
        case .badContainer, .badDatabase, .invalidArguments:
            return "A fatal error occurred: \(error.localizedDescription)"
        default:
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
