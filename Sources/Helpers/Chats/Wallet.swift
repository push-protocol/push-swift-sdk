struct walletType {
  let account: String?
  let signer: SignerType?
}

struct SignerType {
  let privateKey: String?
  //   let signTypedData: ((_ domain: Any, _ types: Any, _ value: Any) -> Promise<String>)?
}

func getWallet(options: walletType) {

}
