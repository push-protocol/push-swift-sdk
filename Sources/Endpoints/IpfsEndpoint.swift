extension PushEndpoint {
  static func getCID(
    env: ENV,
    cid: String
  ) -> Self {
    PushEndpoint(
      env: env,
      path: "ipfs/\(cid)"
    )
  }
}
