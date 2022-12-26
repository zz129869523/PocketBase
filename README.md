# PocketBase

A Swift client for PocketBase.

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
// TODO

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

### Examples
List/Search
``` swift

```

View
``` swift

```

Create
``` swift

```

Update
``` swift

```

Delete
``` swift

```

Auth
``` swift

```

## Todo list
[-] Realtime

[-] File upload and download
