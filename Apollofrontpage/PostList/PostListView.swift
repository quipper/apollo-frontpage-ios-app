//
//  PostListView.swift
//  Apollofrontpage
//
//  Created by hajime-nakamura on 2020/07/21.
//  Copyright © 2020 Quipper. All rights reserved.
//

import SwiftUI
import Apollo

struct PostListView: View {
    @ObservedObject var viewModel: PostListViewModel

    init(viewModel: PostListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List(viewModel.posts, id: \.id) { post in
            PostListCell(post: post, upvoteAction: { post in
                self.viewModel.upvote(on: post.id)
            })
        }
        .onAppear {
            self.viewModel.fetchAllPosts()
        }
        .alert(isPresented: self.$viewModel.showError) {
            Alert(title: Text("エラー"), message: Text(self.viewModel.error!.message))
        }
    }
}

struct PostListView_Previews: PreviewProvider {
    static var previews: some View {
        PostListView(
            viewModel: PostListViewModel(
                apollo: ApolloClient(url: URL(string: "http://localhost:8080/graphql")!)
            )
        )
    }
}
