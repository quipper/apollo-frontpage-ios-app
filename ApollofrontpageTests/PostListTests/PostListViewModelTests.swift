//
//  PostListViewModelTests.swift
//  ApollofrontpageTests
//
//  Created by hajime-nakamura on 2020/07/21.
//  Copyright © 2020 Quipper. All rights reserved.
//

import XCTest
import Combine
import Apollo
@testable import Apollofrontpage

final class PostListViewModelTests: XCTestCase {

    private var subscriptions = Set<AnyCancellable>()

    func testFetchAllPostsSuccess() {
        let mockNetworkTransport = MockNetworkTransport()
        let apollo = ApolloClient(networkTransport: mockNetworkTransport)
        let subject = PostListViewModel(apollo: apollo)

        let expectation = XCTestExpectation(description: "fetch success")

        subject.$posts.dropFirst().sink { posts in
            XCTAssertEqual(posts.count, 3)
            expectation.fulfill()
        }
        .store(in: &subscriptions)

        subject.fetchAllPosts()

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchAllPostsFail() {
        let mockNetworkTransport = MockNetworkTransport(error: PostListError.fetchAllPosts)
        let apollo = ApolloClient(networkTransport: mockNetworkTransport)
        let subject = PostListViewModel(apollo: apollo)

        let expectation = XCTestExpectation(description: "fetch failed")

        subject.$showError.dropFirst().sink {
            XCTAssertTrue($0)
            XCTAssertEqual(subject.error!.message, "Error: fetch all posts failed.")
            expectation.fulfill()
        }
        .store(in: &subscriptions)

        subject.fetchAllPosts()

        wait(for: [expectation], timeout: 1.0)
    }

    func testUpvoteSuccess() {
        let mockNetworkTransport = MockNetworkTransport()
        let apollo = ApolloClient(networkTransport: mockNetworkTransport)
        let subject = PostListViewModel(apollo: apollo)

        let expectation = XCTestExpectation(description: "upvote success")

        subject.$posts.dropFirst(1).sink { posts in
            subject.upvote(on: 1)
            if posts[0].votes == 85 {
                XCTAssertEqual(posts[0].votes, 85)
                expectation.fulfill()
            }
        }
        .store(in: &subscriptions)

        subject.fetchAllPosts()

        wait(for: [expectation], timeout: 1.0)
    }

    func testUpvoteFail() {
        let mockNetworkTransport = MockNetworkTransport(error: PostListError.upvote)
        let apollo = ApolloClient(networkTransport: mockNetworkTransport)
        let subject = PostListViewModel(apollo: apollo)

        let expectation = XCTestExpectation(description: "upvote failed")

        subject.$showError.dropFirst(1).sink {
            XCTAssertTrue($0)
            XCTAssertEqual(subject.error!.message, "Error: upvote failed.")
            expectation.fulfill()
        }
        .store(in: &subscriptions)

        subject.upvote(on: 1)

        wait(for: [expectation], timeout: 1.0)
    }
}
