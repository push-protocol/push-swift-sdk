import SwiftUI
import WalletConnectSign
import Push

struct ContentView: View {
  @State private var showAlert = false

  var body: some View {
    VStack {
      Text("Push Sdk Demo")
        .font(.title)
        .padding()

      Button(action: {
        showAlert = false
        connect()
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

func connect() {
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
