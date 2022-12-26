import XCTest
@testable import PocketBase

final class PocketBaseTests: XCTestCase {
  let testCollection = "users"
  
  //MARK: - Create
//  func test_Collection_Create_HostShouldBeError() async throws {
//    let pb = PocketBase<User>(host: "http://0.0.0.0:0")
//    let dic = await pb.collection(testCollection).create(CreateUserModel.mockData)
//
//    XCTAssertNil(dic)
//  }
  
  func test_Collection_Create_CollectionShouldBeError() async throws {
    let pb = PocketBase<User>()
    let dic = await pb.collection(testCollection + UUID().uuidString).create(CreateUserModel.mockData)
    
    XCTAssertNotNil(dic)
    if let dic {
      let err = try? ErrorResponse(dictionary: dic)
      
      XCTAssertNotNil(err)
      XCTAssertEqual(err?.code, 404)
      XCTAssertEqual(err?.message, "The requested resource wasn\'t found.")
    }
  }
  
  func test_Collection_Create_BodyShouldBeError() async throws {
    let pb = PocketBase<User>()
    let dic = await pb.collection(testCollection).create([UUID().uuidString: UUID().uuidString])
    
    XCTAssertNotNil(dic)
    if let dic {
      let err = try? ErrorResponse(dictionary: dic)
      
      XCTAssertNotNil(err)
      XCTAssertEqual(err?.code, 400)
      XCTAssertEqual(err?.message, "Failed to create record.")
    }
  }
  
  func test_Collection_Create_ShouldBeSuccess() async throws {
    let pb = PocketBase<User>()
    let dic = await pb.collection(testCollection).create(CreateUserModel.mockData)
    
    XCTAssertNotNil(dic)
    if let dic {
      let err = try? ErrorResponse(dictionary: dic)
      
      XCTAssertNil(err)
      if err == nil {
        let user: User? = try? User.dicToStruct(dictionary: dic)
        
        XCTAssertNotNil(user)
        if let user {
          XCTAssertEqual(user.name, CreateUserModel.mockData.name)
          XCTAssertEqual(user.email, CreateUserModel.mockData.email)
          XCTAssertEqual(user.username, CreateUserModel.mockData.username)
          XCTAssertEqual(user.emailVisibility, CreateUserModel.mockData.emailVisibility)
        }
      }
    }
  }
}

struct CreateUserModel: Codable {
  let name: String
  let username: String
  let email: String
  let emailVisibility: Bool
  let password: String?
  let passwordConfirm: String?
  
  static let mockData = CreateUserModel(
    name: "PocketBase",
    username: "pocketbase",
    email: "pocketbase@test.com",
    emailVisibility: true,
    password: "12345678",
    passwordConfirm: "12345678"
  )
}
