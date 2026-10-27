//
//  DataResponseErrorTests.swift
//  LandmarkTests
//

import Testing

@testable import Landmark

struct DataResponseErrorTests {
    @Test func everyErrorHasAReadableReason() {
        let errors: [DataResponseError] = [.emptyData, .missingId, .imageEncodingFailed]

        for error in errors {
            #expect(!error.reason.isEmpty)
        }
        #expect(Set(errors.map(\.reason)).count == errors.count)
    }
}
