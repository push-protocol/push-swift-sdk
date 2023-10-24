import Push
import SwiftUI
import WalletConnectSign

struct ContentView: View {
  @State private var showAlert = false

  var body: some View {
    VStack {
      Text("Push Sdk Demo")
        .font(.title)
        .padding()

      Button(action: {
        showAlert = false
        //        connect()
        Task {
          await connect()
        }
      }) {
        Text("Conect Wallet Connect")
          .font(.headline)
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(10)
      }
      .padding(.horizontal, 40.0)
      .alert(isPresented: $showAlert) {
        Alert(
          title: Text("Alert"), message: Text("Button clicked!"),
          dismissButton: .default(Text("OK")))
      }
    }
  }
}

func connect() async {
  do {
    let user = try await PushUser.get(
      account: "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c", env: .STAGING)!
    print(user)
  } catch {
    print(error)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
