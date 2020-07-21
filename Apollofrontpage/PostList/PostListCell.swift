//
//  PostListCell.swift
//  Apollofrontpage
//
//  Created by hajime-nakamura on 2020/07/21.
//  Copyright © 2020 Quipper. All rights reserved.
//

import SwiftUI

struct PostListCell: View {
    let post: PostDetails
    let upvoteAction: (PostDetails) -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(post.title ?? "")
                HStack {
                    Text(Self.byline(for: post))
                    Text(Self.votesText(for: post))
                }
            }
            Spacer()
            Button("Upvote") {
                self.upvoteAction(self.post)
            }
            .foregroundColor(.blue)
        }
        .padding()
    }

    static private func byline(for post: PostDetails) -> String {
        if let author = post.author {
            return "by \(Self.fullName(for: author))"
        } else {
            return ""
        }
    }

    static private func fullName(for author: PostDetails.Author) -> String {
        [author.firstName, author.lastName].compactMap { $0 }.joined(separator: " ")
    }

    static private func votesText(for post: PostDetails) -> String {
        "\(post.votes ?? 0) vote\(post.votes == 1 ? "" : "s")"
    }
}

struct PostListCell_Previews: PreviewProvider {
    static var previews: some View {
        PostListCell(post:
            PostDetails(
                id: 0,
                title: "Ingroduction to GraphQL",
                votes: 0,
                author:
                PostDetails.Author(
                    firstName: "Tom",
                    lastName: "Coleman"
                )
            ), upvoteAction: { _ in }
        )
            .previewLayout(.sizeThatFits)
    }
}
