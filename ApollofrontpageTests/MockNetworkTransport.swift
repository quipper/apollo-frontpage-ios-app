//
//  MockNetworkTransport.swift
//  ApollofrontpageTests
//
//  Created by hajime-nakamura on 2020/07/22.
//  Copyright © 2020 Quipper. All rights reserved.
//

import Foundation
import Apollo

final class MockNetworkTransport: NetworkTransport {
    let error: Error?

    var clientName = "MockNetworkTransport"
    var clientVersion = "mock_version"

    init(error: Error? = nil) {
        self.error = error
    }

    func send<Operation: GraphQLOperation>(operation: Operation, completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation.Data>, Error>) -> Void) -> Cancellable {
        DispatchQueue.global(qos: .default).async {
            if let error = self.error {
                completionHandler(.failure(error))
            } else {
                completionHandler(
                    .success(
                        GraphQLResponse(
                            operation: operation,
                            body: self.makeJSONObject(with: operation.operationName)
                        )
                    )
                )
            }
        }
        return MockTask()
    }

    private func makeJSONObject(with operationName: String) -> JSONObject {
        let resourceName: String
        if operationName == "AllPosts" {
            resourceName = "all_posts"
        } else if operationName == "UpvotePost" {
            resourceName = "upvote"
        } else {
            fatalError()
        }
        let bundle = Bundle.init(for: type(of: self))
        let path = bundle.path(forResource: resourceName, ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        return try! JSONSerialization.jsonObject(with: data, options: []) as! JSONObject
    }
}

final class MockTask: Cancellable {
    func cancel() {}
}
