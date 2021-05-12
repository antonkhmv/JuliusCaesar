import Foundation
import TdlibKit

struct UserInfo : Decodable, Encodable {
    let id: Int
    let name: String
    let username: String
    let profilePhoto: File?
}


extension UserInfo {
    
    init(_ user: User) {
        profilePhoto = user.profilePhoto?.small
        id = user.id
        name = "\(user.firstName) \(user.lastName)"
        username = user.username
    }
    
}
