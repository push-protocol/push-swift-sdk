import ObjectivePGP

public struct Pgp {
  let publicKey: Data
  let secretKey: Data
}

extension Pgp {
  public func getPublicKey() -> String {
    return
      Armor.armored(self.publicKey, as: .publicKey)
  }

  public func getSecretKey() -> String {
    return
      Armor.armored(self.secretKey, as: .secretKey)
  }

  public static func GenerateNewPgpPair() throws -> Self {
    let key = KeyGenerator().generate(for: "", passphrase: "")

    let publicKey = try key.export(keyType: .public)
    let secretKey = try key.export(keyType: .secret)

    return Pgp(publicKey: publicKey, secretKey: secretKey)
  }
}
