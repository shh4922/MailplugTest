import Foundation

struct BoardListModel: Codable {
    let value : [Board]
    let count : Int
    let offset : Int
    let limit : Int
    let total : Int
}

struct Board: Codable {
    var boardId: Int
    var displayName: String
}
