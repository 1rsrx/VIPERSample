//
//  SignInPresenter.swift
//  VIPERSample
//
//  Created by Hikaru Kuroda on 2022/06/18.
//

import Foundation
import Combine

protocol SignInPresentation: AnyObject {
    func didTapSignInButton(id: String, password: String)
}

class SignInPresenter {
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

extension SignInPresenter: SignInPresentation {
    func didTapSignInButton(id: String, password: String) {
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
}
