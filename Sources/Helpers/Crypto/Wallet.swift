public struct walletType {
  let account: String?
  let signer: Signer?
}

// struct SignerType {
//   let privateKey: String?
//   //   let signTypedData: ((_ domain: Any, _ types: Any, _ value: Any) -> Promise<String>)?
// }

func getWallet(options: walletType) -> walletType {
  var account = options.account;
  if(account != nil) {
    account = pCAIP10ToWallet(address: account!);
  }
  let wallet = walletType(
    account: account,
    signer: options.signer
  );
  return wallet;
}
