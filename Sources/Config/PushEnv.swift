public enum ENV {
  case STAGING
  case PROD
  case DEV
}

extension ENV {
  static func getHost(withEnv env: ENV) -> String {
    switch env {
    case .STAGING:
      return "backend-staging.epns.io"
    case .PROD:
      return "backend.epns.io"
    case .DEV:
      return "backend-dev.epns.io"
    }

  }

}
