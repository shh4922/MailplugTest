import Foundation

/// 최대개수는 30개로
///  offset 이 현재 개수
struct BoardModel: Codable {
    var value: [Post]
    var count: Int
    var offset: Int
    let limit: Int
    let total: Int
}

struct Post: Codable {
    let postId: Int
    var title: String
    let boardId: Int
    let boardDisplayName: String
    let writer: Writer
    let contents: String
    let createdDateTime: String
    let viewCount: Int
    let postType: String //notice - 공지, reply - re
    let isNewPost: Bool
    let hasInlineImage: Bool
    let commentsCount: Int
    let attachmentsCount: Int
    let isAnonymous: Bool
    let isOwner: Bool
    let hasReply: Bool
}

struct Writer: Codable {
    let displayName: String
    let emailAddress: String
}
