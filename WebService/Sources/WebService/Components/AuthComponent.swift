import Apodini
import Shared

struct AuthComponent: Component {
    var content: some Component {
        Group("auth") {
            LoginHandler()
                .operation(.create)
        }
    }
}
