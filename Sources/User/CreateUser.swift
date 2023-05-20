import Web3

public struct CreateUserProps {
  var env: ENV? = .PROD,
    account: String?,
    signer: String,
    version: ENCRYPTION_TYPE?,
    additionalMeta: String?
}

extension User {
  public static func create(options: CreateUserProps) {

  }
}
