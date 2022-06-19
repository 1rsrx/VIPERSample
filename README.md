# VIPERSample
VIPERアーキテクチャの練習用
# VIPER

## VIPERとは
CleanArchitectureをiOS用にしたもの

- View
  - 画面の描画
- Interactor
  - 通信, データの取得(MVCのモデル的な役割)
- Presenter
  - プレゼンテーションロジック(Viewからユーザーアクションを受け取る, Viewに画面更新を依頼)
  - View, Interactor, Routerを保持
- Entity
  - オブジェクト
- Router
  - 画面生成, 画面遷移, DI

### 例: ボタンタップ → データ取得 → 画面に表示 or 画面遷移
1. ViewからPresenterに伝える
2. PresenterがInteracorのメソッドを呼び出す
3. その結果を元にViewを更新 or Routerを使って画面遷移


## 実装
![アプリ](~/Desktop/image.png)

別クラスはプロトコルを介してアクセスする

## 命名
| 役割                 | プロトコル名                     | 実体名                           |
|:---------------------|:---------------------------------|:---------------------------------|
| `View`               | `〜View`               | `〜ViewController`     |
| `Presenter`          | `〜Presentation`       | `〜Presenter`          |
| `Router`             | `〜Wireframe`          | `〜Router`             |
| `Interactor`         | `〜Usecase`        | `〜Interactor`     |
| `Entity`             | -                      | -             |

### Router
役割: Viewの生成, 画面遷移, DI
```swift
protocol SignInWireFrame: AnyObject {
    func transitionToContentView()
}

final class SignInRouter {
    private unowned let viewController: UIViewController

    private init(viewController: UIViewController) {
        self.viewController = viewController
    }

    static func assembleModules() -> UIViewController {
        // presenterにview, router, interactorを渡す
        let view = SignInViewController()
        let router = SignInRouter(viewController: view)
        let interactor = SignInInteractor(auth: Auth())
        let presenter = SignInPresenter(view: view, router: router, interactor: interactor)

        // viewのpresenterにセット
        view.presenter = presenter
        return view
    }
}

extension SignInRouter: SignInWireFrame {
    func transitionToContentView() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window!.rootViewController = ContentViewController()
    }
}
```

### View
役割: 画面描画, ユーザーアクションをPresenterに伝える
```swift
protocol SignInView: AnyObject {
    func setButtonEnable(isEnabled: Bool)
    func showError(title: String, message: String)
}

final class SignInViewController: UIViewController {

    private let stackView = UIStackView()
    private let idTextField = PaddingTextField(top: 5, left: 5, bottom: 5, right: 5)
    private let passwordTextField = PaddingTextField(top: 5, left: 5, bottom: 5, right: 5)
    private let signInButton = UIButton()

    var presenter: SignInPresentation!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {}

    private func didChangeIDOrPassword() {
        let id = idTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        presenter.didChange(id, or: password)
    }

    @objc private func didChangeID(_ sender: UITextField) {
        didChangeIDOrPassword()
    }

    @objc private func didChangePassword(_ sender: UITextField) {
        didChangeIDOrPassword()
    }

    @objc private func didTapSignInButton(_ sender: UIButton) {
        let id = idTextField.text ?? ""
        let pass = passwordTextField.text ?? ""
        presenter.didTapSignInButton(id: id, password: pass)
    }
}

// Presenterがこのメソッドを呼び出す
extension SignInViewController: SignInView {
    func setButtonEnable(isEnabled: Bool) {
        signInButton.isEnabled = isEnabled

        let alpha = isEnabled ? 1 : 0.2
        signInButton.alpha = alpha
    }

    func showError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "閉じる", style: .default)
        alert.addAction(closeAction)
        self.present(alert, animated: true)
    }
}
```

### Presenter
ViewとInteracorの仲介, Viewの画面更新用のメソッドを呼び出す, Routerの画面遷移メソッドを呼び出す
```swift
protocol SignInPresentation: AnyObject {
    func didTapSignInButton(id: String, password: String)
    func didChange(_ id: String, or password: String)
}

class SignInPresenter {
    // view, router, ineractorを保持
    // Routerで画面生成時に注入する
    private weak var view: SignInView?
    private let router: SignInWireFrame
    private let interactor: SignInInteractor

    private var cancellables = Set<AnyCancellable>()

    init(view: SignInView, router: SignInWireFrame, interactor: SignInInteractor) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
}

// Viewから呼び出されるメソッド
extension SignInPresenter: SignInPresentation {
    func didTapSignInButton(id: String, password: String) {
        // interactorのメソッドを呼び出し、結果に応じて処理を実行
        interactor.signIn(id: id, password: password)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let err):
                    self.view?.showError(title: "エラー", message: err.detail)
                }
            } receiveValue: { id in
                self.router.transitionToContentView()
            }
            .store(in: &cancellables)
    }

    func didChange(_ id: String, or password: String) {
        let canSignIn = (id.count > 3) && (password.count > 5)
        view?.setButtonEnable(isEnabled: canSignIn)
    }
}
```

### Interactor
通信, データ取得

```swift
protocol SignInUsecase: AnyObject {
    func signIn(id: String, password: String) -> Future<String, SignInError>
}

final class SignInInteractor {

    private let auth: Auth

    init(auth: Auth) {
        self.auth = auth
    }
}

// Presenterから呼び出されるメソッド
extension SignInInteractor: SignInUsecase {
    func signIn(id: String, password: String) -> Future<String, SignInError> {
        return Future { promise in
            promise(.success("user id"))
//            promise(.failure(SignInError(detail: "パスワードが違います")))
        }
    }
}

// FirebaseAuthをイメージ
class Auth {

}
```

### Entity
```swift
struct SignInError: Error {
    let detail: String
}
```