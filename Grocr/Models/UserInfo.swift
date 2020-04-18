import Foundation
import Firebase

struct UserInfo {
  
  let ref: DatabaseReference?
  let key: String
  let userName: String
  let type: Int
  let familyUID: String
  
  public init(userName: String, type: Int, familyUID: String, key: String = "") {
    self.ref = nil
    self.key = key
    self.userName = userName
    self.type = type
    self.familyUID = familyUID
  }
  
  public init?(snapshot: DataSnapshot) {
    guard
      let value = snapshot.value as? [String: AnyObject],
      let userName = value["userName"] as? String,
      let type = value["type"] as? Int,
      let familyUID = value["familyUID"] as? String else {
        return nil
    }
    
    self.ref = snapshot.ref
    self.key = snapshot.key
    self.userName = userName
    self.type = type
    self.familyUID = familyUID
  }
  
  func toAnyObject() -> Any {
    return [
      "userName": userName,
      "type": type,
      "familyUID": familyUID
    ]
  }
}
