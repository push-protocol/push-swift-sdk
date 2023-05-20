public enum ENCRYPTION_TYPE: Swift.String, Swift.CodingKey {
  case PGP_V1 = "x25519-xsalsa20-poly1305"
  case PGP_V2 = "aes256GcmHkdfSha256"
  case PGP_V3 = "eip191-aes256-gcm-hkdf-sha256"
  case NFTPGP_V1 = "pgpv1:nft"
}
