//
//  PostListViewModel.swift
//  Apollofrontpage
//
//  Created by hajime-nakamura on 2020/07/21.
//  Copyright © 2020 Quipper. All rights reserved.
//

import Foundation
import Apollo
import SwiftUI

enum PostListError: Error {
    case fetchAllPosts(Error)
    case upvote(Error)
}

final class PostListViewModel: ObservableObject {
    private let apollo: ApolloClient

    @Published var posts: [PostDetails] = []
    @Published var showError = false

    private var error: PostListError? {
        didSet {
            showError = true
        }
    }

    var errorDescription: String {
        guard let error = error else { return "" }
        switch error {
        case .fetchAllPosts(let error):
            return error.localizedDescription
        case .upvote(let error):
            return error.localizedDescription
        }
    }

    init(apollo: ApolloClient) {
        self.apollo = apollo
    }

    func fetchAllPosts() {
        apollo.fetch(query: AllPostsQuery()) { result in
            switch result {
            case .success(let graphQLResult):
                if let posts = graphQLResult.data?.posts {
                    self.posts = posts.map { $0.fragments.postDetails }
                } else {
                    self.posts = []
                }
            case .failure(let error):
                self.error = .fetchAllPosts(error)
            }
        }
    }

    func upvote(on postId: Int) {
        apollo.perform(mutation: UpvotePostMutation(postId: postId)) { result in
            switch result {
            case .success(let graphQLResult):
                guard let upvotePost = graphQLResult.data?.upvotePost,
                    let index = self.posts.firstIndex(where: { $0.id == upvotePost.id }) else {
                        return
                }
                var post = self.posts[index]
                post.votes = upvotePost.votes
                self.posts.remove(at: index)
                self.posts.insert(post, at: index)
            case .failure(let error):
                self.error = .upvote(error)
            }
        }
    }
}
