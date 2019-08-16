//
//  TouchIDAuthentication.swift
//  TouchMeIn
//
//  Created by Yury Popov on 21/07/2019.
//  Copyright © 2019 SwiftLab. All rights reserved.
//

import Foundation
import LocalAuthentication

class TouchIDAuth {
    let context = LAContext()
    
    // Проверка доступности TouchID или Face
    func canEvaluatePolicy() -> Bool {
        
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func authenticateUser(completion: @escaping (String?) -> Void) {
        // В параметре передается обработчик, который выполнится после завершения аутентификации
        
        // Проверить доступность TouchID
        guard canEvaluatePolicy() else {
            completion("Touch/Face ID не доступен")
            return
        }
        
        // Запустить функцию проверки отпечатка пальца \ лица. После завершения вызвать блок кода completion()
        let biometryType = context.biometryType == .faceID ? "Face ID" : "Touch ID"
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Вход с помощью \(biometryType)") { (success, evaluateError) in
            //Блок кода завершения проверки
            if success {
                DispatchQueue.main.async {
                    //аутентификация пройдена успешно, выполнить соответсвующие действия
                    completion(nil)
                }
            } else {
                //Обработка ошибок
                let message: String
                
                switch evaluateError {
                case LAError.authenticationFailed?:
                    message = "Не удалось распознать вашу личность"
                case LAError.userCancel?:
                    message = "Вы нажали отмену."
                case LAError.userFallback?:
                    message = "Вы нажали ввод пароля."
                    
                default:
                    message = "\(biometryType) возможно не настроен"
                }
                
                completion(message)
            }
        }
    }
}
