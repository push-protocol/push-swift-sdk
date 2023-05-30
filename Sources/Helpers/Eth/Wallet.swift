public struct Wallet{
   let signer: Signer
  let account :String

   public init(signer:Signer)async throws{
    self.signer = signer
    
      self.account = try await signer.getAddress()
   }
}

extension Wallet {
  public func getEip191Signature(message: String, version:String="v1")async throws ->String  {
    let hash = try await signer.getEip191Signature(message: message)
    let sigType  = version == "v2" ? "eip191v2" : "eip191"
    return "\(sigType):\(hash)"
  }
}
