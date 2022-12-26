//
//  Collection.swift
//  
//
//  Created by zz129869523 on 2022/12/22.
//

import Foundation

protocol CollectionMethod {
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
}

public actor Collection<UserModel: AuthModel>: CollectionMethod {
  private var authStore: AuthStore<UserModel>
  private var collection: String
  private let networkService: NetworkServiceContract
  
  init(_ authStore: AuthStore<UserModel>, _ collection: String) {
    self.authStore = authStore
    self.collection = collection
    self.networkService = NetworkService()
  }
  
  init(_ authStore: AuthStore<UserModel>, _ collection: String, networkService: NetworkServiceContract) {
    self.authStore = authStore
    self.collection = collection
    self.networkService = networkService
  }
  
  // MARK: - List/Search
  /// Fetch a paginated records list, supporting sorting and filtering.
  /// - Parameters:
  ///   - page: The page (aka. offset) of the paginated list (default to 1).
  ///   - perPage: Specify the max returned records per page (default to 30).
  ///   - filter: Filter the returned records. Ex.: `filter = "created>'2022-01-01'"`
  ///   - sort: Specify the records order attribute(s). Add - / + (default) in front of the attribute for DESC / ASC order. Ex.: DESC by created and ASC by id `sort = "-created,id"`
  ///   - expand: Auto expand record relations. Ex.: `expand = "relField1,relField2.subRelField"`
  /// - Returns: <#description#>
  public func getList(page: Int = 1, perPage: Int = 30, filter: String = "", sort: String = "", expand: String = "") async -> [String: Any]? {
    var query: [URLQueryItem] = []
    query.append(URLQueryItem(name: "page", value: "\(page)"))
    query.append(URLQueryItem(name: "perPage", value: "\(perPage)"))
    query.append(URLQueryItem(name: "filter", value: "\(filter)"))
    query.append(URLQueryItem(name: "sort", value: "\(sort)"))
    query.append(URLQueryItem(name: "expand", value: "\(expand)"))
    return try? await self.networkService.requset(endpoint: Endpoint<[String: String]>.fatch(self.collection, queryItems: query))
  }
  
  public func getList<R: Codable>(page: Int = 1, perPage: Int = 30, filter: String = "", sort: String = "", expand: String = "") async -> ListResult<R>? {
    let dic = await getList(page: page, perPage: perPage, filter: filter, sort: sort, expand: expand)
    return try? Global.dicToStruct(dictionary: dic ?? [:]) as ListResult<R>
  }
  
  /// Fetch all records at once via getFullList.
  /// - Parameters:
  ///   - batch: Specify the max returned records.
  ///   - filter: Filter the returned records. Ex.: `filter = "created>'2022-01-01'"`
  ///   - sort: Specify the records order attribute(s). Add - / + (default) in front of the attribute for DESC / ASC order. Ex.: DESC by created and ASC by id `sort = "-created,id"`
  ///   - expand: Auto expand record relations. Ex.: `expand = "relField1,relField2.subRelField"`
  /// - Returns: <#description#>
  public func getFullList<R: Codable>(batch: Int = 100, filter: String = "", sort: String = "", expand: String = "") async -> [R] {
    let dic = await getList(page: 1, perPage: batch, filter: filter, sort: sort, expand: expand)
    let list = try? Global.dicToStruct(dictionary: dic ?? [:]) as ListResult<R>
    return list?.items ?? []
  }
  
  /// Fetch only the first record that matches the specified filter.
  /// - Parameters:
  ///   - filter: Filter the returned records. Ex.: `filter = "created>'2022-01-01'"`
  ///   - sort: Specify the records order attribute(s). Add - / + (default) in front of the attribute for DESC / ASC order. Ex.: DESC by created and ASC by id `sort = "-created,id"`
  ///   - expand: Auto expand record relations. Ex.: `expand = "relField1,relField2.subRelField"`
  /// - Returns: <#description#>
  public func getFirstListItem<R: Codable>(filter: String = "", sort: String = "", expand: String = "") async -> R? {
    let dic = await getList(page: 1, perPage: 1, filter: filter, sort: sort, expand: expand)
    let list = try? Global.dicToStruct(dictionary: dic ?? [:]) as ListResult<R>
    return list?.items.first
  }
  
  // MARK: - View
  /// Fetch a single record.
  /// - Parameters:
  ///   - id: ID of the record to view.
  ///   - expand: Auto expand record relations. Ex.: `expand = "relField1,relField2.subRelField"`
  /// - Returns: <#description#>
  public func getOne(id: String, expand: String = "") async -> [String: Any]? {
    let query: [URLQueryItem] = [URLQueryItem(name: "expand", value: "\(expand)")]
    return try? await self.networkService.requset(endpoint: Endpoint<[String: String]>.fatch(self.collection, queryItems: query, id: id))
  }
  
  public func getOne<R: Codable>(id: String, expand: String = "") async -> R? {
    let dic = await getOne(id: id , expand: expand)
    return try? Global.dicToStruct(dictionary: dic ?? [:]) as R
  }
  
  // MARK: - Create
  /// Create a new record.
  /// - Parameter body: A request body is data sent by the client to your API.
  /// - Returns: <#description#>
  public func create<BodyType: Codable>(_ body: BodyType) async -> [String: Any]? {
    return try? await self.networkService.requset(endpoint: Endpoint<BodyType>.create(self.collection, body: body))
  }
  
  public func create<BodyType: Codable, R: Codable>(_ body: BodyType) async -> R? {
    let dic: [String: Any]? = await create(body)
    return try? Global.dicToStruct(dictionary: dic ?? [:]) as R
  }
  
  // MARK: - Update
  /// Update a single record.
  /// - Parameters:
  ///   - id: ID of the record to delete.
  ///   - body: A request body is data sent by the client to your API.
  ///   - expand: Auto expand record relations. Ex.: `expand = "relField1,relField2.subRelField"`
  /// - Returns: <#description#>
  public func update<BodyType: Codable>(_ id: String, body: BodyType, expand: String = "") async -> [String: Any]? {
    let query: [URLQueryItem] = [URLQueryItem(name: "expand", value: "\(expand)")]
    return try? await self.networkService.requset(endpoint: Endpoint<BodyType>.update(self.collection, body: body, queryItems: query, id: id))
  }
  
  public func update<BodyType: Codable, R: Codable>(_ id: String, body: BodyType, expand: String = "") async -> R? {
    let dic: [String: Any]? = await update(id, body: body, expand: expand)
    return try? Global.dicToStruct(dictionary: dic ?? [:]) as R
  }
  
  // MARK: - Delete
  /// Delete a single record.
  /// - Parameter id: ID of the record to delete.
  /// - Returns: <#description#>
  public func delete(_ id: String) async -> [String: Any]? {
    return try? await self.networkService.requset(endpoint: Endpoint<[String: String]>.delete(self.collection, id: id))
  }
  
  // MARK: - Realtime
  
  // MARK: - Auth
  /// Returns new auth token and account data by a combination of username/email and password.
  /// - Parameters:
  ///   - identity: The username or email of the record to authenticate.
  ///   - password: The auth record password.
  ///   - expand: Auto expand record relations. Ex.: `expand = "relField1,relField2.subRelField"`
  /// - Returns: <#description#>
  public func authWithPassword(_ identity: String, _ password: String, _ expand: String = "") async -> [String: Any]? {
    let query: [URLQueryItem] = [URLQueryItem(name: "expand", value: "\(expand)")]
    let dic: [String: Any]? = try? await self.networkService.requset(
      endpoint: Endpoint<[String: String]>.authWithPassword(
        self.collection,
        body: ["identity": identity, "password": password],
        queryItems: query
      )
    )
    
    self.authStore.storageWith(dic)
    
    return dic
  }
  
  public func authWithPassword<UserModel: AuthModel>(_ identity: String, _ password: String) async -> AuthResponse<UserModel>? {
    let dic: [String: Any]? = await authWithPassword(identity, password)
    return try? Global.dicToStruct(dictionary: dic ?? [:]) as AuthResponse<UserModel>
  }
  
  /// Authenticate with an OAuth2 provider and returns a new auth token and record data.
  /// - Parameters:
  ///   - provider: The name of the OAuth2 client provider (eg. "google").
  ///   - code: The authorization code returned from the initial request.
  ///   - codeVerifier: The code verifier sent with the initial request as part of the code_challenge.
  ///   - redirectUrl: The redirect url sent with the initial request.
  ///   - createData: Optional data that will be used when creating the auth record on OAuth2 sign-up.
  ///                 The created auth record must comply with the same requirements and validations in the regular create action.
  ///   - expand: Auto expand record relations. Ex.: `expand = "relField1,relField2.subRelField"`
  /// - Returns: <#description#>
  public func authWithOAuth2(
    _ provider: OAuthProvider,
    code: String,
    codeVerifier: String,
    redirectUrl: String,
    createData: [String: String] = [:],
    expand: String = ""
  ) async -> [String: Any]? {
    let query: [URLQueryItem] = [URLQueryItem(name: "expand", value: "\(expand)")]
    let dic: [String: Any]? = try? await self.networkService.requset(
      endpoint: Endpoint<OAuth2Requset>.authWithOAuth2(
        self.collection,
        body: OAuth2Requset(provider: provider, code: code, codeVerifier: codeVerifier, redirectUrl: redirectUrl, createData: createData),
        queryItems: query
      )
    )
    
    self.authStore.storageWith(dic)
    
    return dic
  }
  
  public func authWithOAuth2<UserModel: AuthModel>(
    _ provider: OAuthProvider,
    code: String,
    codeVerifier: String,
    redirectUrl: String,
    createData: [String: String] = [:],
    expand: String = ""
  ) async -> AuthResponse<UserModel>? {
    let dic: [String: Any]? = await authWithOAuth2(provider, code: code, codeVerifier: codeVerifier, redirectUrl: redirectUrl, createData: createData, expand: expand)
    return try? Global.dicToStruct(dictionary: dic ?? [:]) as AuthResponse<UserModel>
  }
  
  /// Returns a new auth response (token and record data) for an already authenticated record.
  /// - Parameter expand: Auto expand record relations. Ex.: `expand = "relField1,relField2.subRelField"`
  /// - Returns: <#description#>
  public func authRefresh(expand: String = "") async -> [String: Any]? {
    let query: [URLQueryItem] = [URLQueryItem(name: "expand", value: "\(expand)")]
    let dic: [String: Any]? = try? await self.networkService.requset(endpoint: Endpoint<[String: String]>.authRefresh(self.collection, queryItems: query))
    
    self.authStore.storageWith(dic)
    
    return dic
  }
  
  public func authRefresh<UserModel: AuthModel>(expand: String = "") async -> AuthResponse<UserModel>? {
    let dic: [String: Any]? = await authRefresh(expand: expand)
    return try? Global.dicToStruct(dictionary: dic ?? [:]) as AuthResponse<UserModel>
  }
  
  /// Sends users verification email request.
  /// - Parameter email: The auth record email address to send the verification request (if exists).
  /// - Returns: <#description#>
  public func requestVerification(_ email: String) async -> [String: Any]? {
    return try? await self.networkService.requset(endpoint: Endpoint<[String: String]>.requestVerification(self.collection, body: ["email": email]))
  }
  
  /// Sends users password reset email request.
  /// - Parameter email: The auth record email address to send the password reset request (if exists).
  /// - Returns: <#description#>
  public func requestPasswordReset(_ email: String) async -> [String: Any]? {
    return try? await self.networkService.requset(endpoint: Endpoint<[String: String]>.requestPasswordReset(self.collection, body: ["email": email]))
  }
  
  /// Sends users email change request.
  /// - Parameter newEmail: The new email address to send the change email request.
  /// - Returns: <#description#>
  public func requestEmailChange(_ newEmail: String) async -> [String: Any]? {
    return try? await self.networkService.requset(endpoint: Endpoint<[String: String]>.requestEmailChange(self.collection, body: ["newEmail": newEmail]))
  }
  
  /// Returns a public list with all allowed users authentication methods.
  /// - Returns: <#description#>
  public func listAuthMethods() async -> [String: Any]? {
    return try? await self.networkService.requset(endpoint: Endpoint<[String: String]>.listAuthMethods(self.collection))
  }
  
  public func listAuthMethods() async -> AuthMethods? {
    let dic: [String: Any]? = await listAuthMethods()
    return try? Global.dicToStruct(dictionary: dic ?? [:]) as AuthMethods
  }
  
  /// Returns a list with all OAuth2 providers linked to a single users.
  /// Only admins and the account owner can access this action.
  /// - Parameter id: ID of the auth record.
  /// - Returns: <#description#>
  public func listExternalAuths(_ id: String) async -> [String: Any]? {
    return try? await self.networkService.requset(endpoint: Endpoint<[String: String]>.listExternalAuths(self.collection, id: id))
  }
  
  public func listExternalAuths(_ id: String) async -> [AuthMethod] {
    let dic: [String: Any]? = await listExternalAuths(id)
    let result = try? Global.dicToStruct(dictionary: dic ?? [:]) as [AuthMethod]
    return result ?? []
  }
  
  /// Unlink a single external OAuth2 provider from users record.
  /// Only admins and the account owner can access this action.
  /// - Parameters:
  ///   - id: ID of the auth record.
  ///   - provider: The name of the auth provider to unlink, eg. google, twitter, github, etc.
  /// - Returns: <#description#>
  public func unlinkExternalAuth(_ id: String, provider: OAuthProvider) async -> [String: Any]? {
    return try? await self.networkService.requset(endpoint: Endpoint<[String: String]>.unlinkExternalAuth(self.collection, id: id, provider: provider))
  }
}
