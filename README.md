# PocketBase

The specific usage is similar to that provided by [pocketbase](https://pocketbase.io/docs/client-side-integration/).

## Feature
- List/Search
- View
- Create
- Update
- Delete
- Realtime
- Auth

## Getting Started

### As you are all aware
Make sure to enable PocketBase first, please refer to [pocketbase](https://github.com/pocketbase/pocketbase) for specific usage methods

### Install

#### Swift Package Manager
1. Insert url of this SPM in your XCode Project with `File → Add Package → Copy Dependency`.
```
https://github.com/zz129869523/PocketBase
```
2. Import the framework:
``` swift
import PocketBase
```

### Usage
#### Application url 
``` swift
let client = PocketBase<User>() // default is http://0.0.0.0:8090
let client = PocketBase<User>(host: "https://your_domain")
```

#### Custom authStore
If you want to customize the default authStore(User), you can extend it and pass a new custom struct to the client:
``` swift
struct CustomUser: AuthModel {
  var id: String?
  var collectionId: String?
  var collectionName: String?
  var created: String?
  var updated: String?
  var username: String?
  var verified: Bool?
  var emailVisibility: Bool?
  var email: String?
  var name: String?
  var avatar: String?
  
  var deactivation: Bool?
}

let client = PocketBase<CustomUser>()

print(client.authStore.model?.deactivation ?? false)
```

#### Instance
``` swift
@main
struct ChartTestApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(PocketBase<User>()) // <-- 1
    }
  }
}

struct ContentView: View {
  @EnvironmentObject var client: PocketBase<User> // <-- 2

  var body: some View {
    // ...
  }
```
or 
``` swift
struct ContentView: View {
  let client = PocketBase<User>() // choose one of three
  @StateObject var client = PocketBase<User>() // choose one of three
  @ObservedObject var client = PocketBase<User>() // choose one of three

  var body: some View {
    // ...
  }
```

#### List/Search
``` swift
struct Post: Codable, Identifiable { // or implement BaseModel
  var id: String?
  var title: String
}

extension Post {
  init(dictionary: [String: Any]) throws {
    self = try JSONDecoder().decode(Self.self, from: JSONSerialization.data(withJSONObject: dictionary))
  }
}

Task {
  // getList
  let dic = await client.collection("posts").getList() // return type of [String : Any]?

  if let dic {
    let err = try? ErrorResponse(dictionary: dic)
    // Handle errors such as status code 400 404 
    print(err?.code)
    print(err?.message)
    
    if err == nil, let result: ListResult<Post> = try? Post(dictionary: dic) {
      print(result.items)
    }
  }

  // or 

  let posts: ListResult<Post>? = await client.collection("posts").getList()
  if let listResult: ListResult<Post> = await client.collection("posts").getList() {
    self.posts = listResult.items
  }

  // getFullList
  let posts: [Post] = await client.collection("posts").getFullList(batch: 200, filter: "created<'2022-12-26 11:10:08'", sort: "-created")

  // getFirstListItem
  let post: Post? = await client.collection("posts").getFirstListItem()
  if let post: Post = await client.collection("posts").getFirstListItem() {
    // ...
  }
}
```

#### View
``` swift
Task {
  let post: Post? = await client.collection("posts").getOne(id: "RECORD_ID")
}
```

#### Create
``` swift
Task {
  let post: Post? = await client.collection("posts").create(["title": "hello pocketbase"])
  let post: Post? = await client.collection("posts").create(Post(title: "hello pocketbase"))
}
```

#### Update
``` swift
Task {
  let post: Post? = await client.collection("posts").update("RECORD_ID", body: ["title": "hello pocketbase"])
  let post: Post? = await client.collection("posts").update("RECORD_ID", body: Post(title: "hello pocketbase"))
}
```

#### Delete
``` swift
Task {
  let dic = await client.collection("posts").delete("RECORD_ID")
}
```

#### Realtime
``` swift
// Subscribe to changes in any posts record
client.collection("posts").subscribe("RECORD_ID") { dict in
  print(dict)
}

// Subscribe to changes only in the specified record
client.collection("posts").subscribe("*") { dict in
  if let result: Event<Post> = try? Utils.dictionaryToStruct(dictionary: dict ?? [:]) { // Event<Type> Can use
    switch result.action {
    case .create:
      self.posts.append(result.record)
    case .update:
      if let row = self.posts.firstIndex(where: { $0.id == result.record.id }) {
        self.posts[row] = result.record
      }
    case .delete:
      self.posts = self.posts.filter { $0.id != result.record.id }
    }
  }
}

// Unsubscribe
client.collection('posts').unsubscribe('RECORD_ID') // remove all 'RECORD_ID' subscriptions
client.collection('posts').unsubscribe('*') // remove all '*' topic subscriptions
client.collection('posts').unsubscribe() // remove all subscriptions in the collection
```

#### Auth
``` swift
Task {
  // authWithPassword
  let _ = await client.collection("users").authWithPassword("pocketbase@test.email", "12345678")
  let response: AuthResponse<User>? = await client.collection("users").authWithPassword("pocketbase@test.email", "12345678")
  print(response?.token)
  print(response?.record)

  print(client.authStore.isValid)
  print(client.authStore.token)
  print(client.authStore.model.id)

  // "logout" the last authenticated account
  client.authStore.clear()

  // authWithOAuth2
  let _ = await client.collection("users").authWithOAuth2(.google, code: "CODE", codeVerifier: "VERIFIER", redirectUrl: "REDIRECT_URL")

  // authRefresh
  let _ = await client.collection("users").authRefresh()

  // requestVerification
  let _ = await client.collection("users").requestVerification("email")

  // requestPasswordReset
  let _ = await client.collection("users").requestPasswordReset("email")

  // requestEmailChange
  let _ = await client.collection("users").requestEmailChange("email")

  // listAuthMethods
  let authMethods: AuthMethods? = await client.collection("users").listAuthMethods()
  print(authMethods?.authProviders)

  // listExternalAuths
  let authMethod: [AuthMethod] = await client.collection("users").listExternalAuths("id")
  print(authMethod)

  // unlinkExternalAuth
  let _ = await client.collection("users").unlinkExternalAuth("id", provider: .google)
}
```

#### AuthStore
``` swift
print(client.authStore.isValid)
print(client.authStore.token)
print(client.authStore.model.id)

// "logout" the last authenticated account
client.authStore.clear()
```

### API
``` swift
// MARK: - List/Search
func getList(page: Int, perPage: Int, filter: String, sort: String, expand: String) async -> [String: Any]?
func getList<R: Codable>(page: Int, perPage: Int, filter: String, sort: String, expand: String) async -> ListResult<R>?
func getFullList<R: Codable>(batch: Int, filter: String, sort: String, expand: String) async -> [R]
func getFirstListItem<R: Codable>(filter: String, sort: String, expand: String) async -> R?

// MARK: - View
func getOne(id: String, expand: String) async -> [String: Any]?
func getOne<R: Codable>(id: String, expand: String) async -> R?

// MARK: - Create
func create<BodyType: Codable>(_ body: BodyType) async -> [String: Any]?
func create<BodyType: Codable, R: Codable>(_ body: BodyType) async -> R?

// MARK: - Update
func update<BodyType: Codable>(_ id: String, body: BodyType, expand: String) async -> [String: Any]?
func update<BodyType: Codable, R: Codable>(_ id: String, body: BodyType, expand: String) async -> R?

// MARK: - Delete
func delete(_ id: String) async -> [String: Any]?

// MARK: - Realtime
func subscribe(_ recordId: String, completion: @escaping ([String: Any]?) -> Void)
func unsubscribe(_ recordId: String)

// MARK: - Auth
func authWithPassword(_ identity: String, _ password: String, _ expand: String) async -> [String: Any]?
func authWithPassword<UserModel: AuthModel>(_ identity: String, _ password: String) async -> AuthResponse<UserModel>?

func authWithOAuth2(_ provider: OAuthProvider, code: String, codeVerifier: String, redirectUrl: String, createData: [String: String], expand: String) async -> [String: Any]?
func authWithOAuth2<UserModel: AuthModel>(_ provider: OAuthProvider, code: String, codeVerifier: String, redirectUrl: String, createData: [String: String], expand: String) async -> AuthResponse<UserModel>?

func authRefresh(expand: String) async -> [String: Any]?
func authRefresh<UserModel: AuthModel>(expand: String) async -> AuthResponse<UserModel>?

func requestVerification(_ email: String) async -> [String: Any]?
func requestPasswordReset(_ email: String) async -> [String: Any]?
func requestEmailChange(_ email: String) async -> [String: Any]?

func listAuthMethods() async -> [String: Any]?
func listAuthMethods() async -> AuthMethods?

func listExternalAuths(_ id: String) async -> [String: Any]?
func listExternalAuths(_ id: String) async -> [AuthMethod]

func unlinkExternalAuth(_ id: String, provider: OAuthProvider) async -> [String: Any]?
```

## Todo list
- Example
- File upload and download
