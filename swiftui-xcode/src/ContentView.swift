import SwiftUI

let screenWidth: CGFloat = 320
let screenHeight: CGFloat = 80

struct ContentView: View {
    var body: some View {
        Text("Hello from Nix!")
            .frame(width: screenWidth, height: screenHeight)
    }
}

// Preview provider for Xcode (works in both Xcode and SPM builds)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
