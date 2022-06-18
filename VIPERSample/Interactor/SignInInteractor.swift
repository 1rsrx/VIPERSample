//
//  SignInInteractor.swift
//  VIPERSample
//
//  Created by Hikaru Kuroda on 2022/06/18.
//

import Foundation
import Combine

protocol SignInUsecase: AnyObject {
    func signIn(id: String, password: String) -> Future<String, SignInError>
}

final class SignInInteractor {

    private let auth: Auth

    init(auth: Auth) {
        self.auth = auth
    }
}

extension SignInInteractor: SignInUsecase {
    func signIn(id: String, password: String) -> Future<String, SignInError> {
        return Future { promise in
//            promise(.success("user id"))
            promise(.failure(SignInError(detail: "パスワードが違います")))
        }
    }
}

class Auth {

}
