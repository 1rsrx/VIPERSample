//
//  SignInRouter.swift
//  VIPERSample
//
//  Created by Hikaru Kuroda on 2022/06/18.
//

import Foundation
import UIKit

protocol SignInWireFrame: AnyObject {
    func transitionToContentView()
}

final class SignInRouter {
    private unowned let viewController: UIViewController

    private init(viewController: UIViewController) {
        self.viewController = viewController
    }

    static func assembleModules() -> UIViewController {
        let view = SignInViewController()
        let router = SignInRouter(viewController: view)
        let interactor = SignInInteractor(auth: Auth())
        let presenter = SignInPresenter(view: view, router: router, interactor: interactor)

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
