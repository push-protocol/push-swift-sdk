public enum ENCRYPTION_TYPE: Swift.String, Swift.CodingKey {
  case PGP_V1 = "x25519-xsalsa20-poly1305"
  case PGP_V2 = "aes256GcmHkdfSha256"
  case PGP_V3 = "eip191-aes256-gcm-hkdf-sha256"
  case NFTPGP_V1 = "pgpv1:nft"
}

public enum CONSTANTS {
  public enum PAGINATION {
    public static let INITIAL_PAGE = 1
    public static let LIMIT = 10
    public static let LIMIT_MIN = 1
    public static let LIMIT_MAX = 50
  }

  public static let DEFAULT_CHAIN_ID = 5
  public static let ETH_CHAINS = [1, 5]
}
