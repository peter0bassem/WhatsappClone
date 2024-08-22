//
//  AuthTextField.swift
//  Whatsapp
//
//  Created by iCommunity app on 22/08/2024.
//

import SwiftUI

struct AuthTextField: View {
    let type: InputType
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: type.imageName)
                .fontWeight(.semibold)
                .frame(width: 30)
            
            switch type {
            case .password:
                SecureField(type.placeholder, text: $text)
                    .tint(.white)
                    .keyboardType(type.keyboardType)
            default:
                TextField(type.placeholder, text: $text)
                    .tint(.white)
                    .keyboardType(type.keyboardType)
                    .textInputAutocapitalization(type.autoCapitalization)
            }
        }
        .foregroundStyle(.white)
        .padding()
        .background(Color.white.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 16)
    }
    
    enum InputType {
        case email, password, custom(_ iconName: String, _ placeholder: LocalizedStringKey, keyboardType: UIKeyboardType, autoCapitalization: TextInputAutocapitalization?)
        
        var placeholder: LocalizedStringKey {
            switch self {
            case .email:
                return "Email"
            case .password:
                return "Password"
            case .custom(_, let placeholder, _, _):
                return placeholder
            }
        }
        
        var imageName: String {
            switch self {
            case .email:
                return "envelope"
            case .password:
                return "lock"
            case .custom(let imageName, _, _, _):
                return imageName
            }
        }
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .email:
                return .emailAddress
            case .password:
                return .default
            case .custom(_, _, let keyboardType, _):
                return keyboardType
            }
        }
        
        var autoCapitalization: TextInputAutocapitalization? {
            switch self {
            case .email:
                return .never
            case .password:
                return nil
            case .custom(_, _, _, let autoCapitalization):
                return autoCapitalization
            }
        }
    }
}

#Preview {
    ZStack {
        Color.teal
        VStack {
            AuthTextField(type: .email, text: .constant(""))
            AuthTextField(type: .password, text: .constant(""))
            AuthTextField(type: .custom("birthday.cake", "Birthday", keyboardType: .default, autoCapitalization: nil), text: .constant(""))
        }
    }
}
