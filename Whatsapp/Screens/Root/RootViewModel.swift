//
//  RootViewModel.swift
//  Whatsapp
//
//  Created by iCommunity app on 23/08/2024.
//

import Foundation
import Combine

final class RootViewModel: ObservableObject {
    @Published private(set) var authState: AuthState = .pending
    
    private var cancellable: AnyCancellable?
    private var uploadPhotocancellable: AnyCancellable?
    
    init() {
        Task {
            cancellable = await AuthProviderServiceImp.shared.authState
                .receive(on: DispatchQueue.main)
                .sink { [weak self] authState in
                    self?.authState = authState
                }
        }
        
        /// working
//        FirebaseHelper.uploadImage(image: .stubImage0, for: .photoMessage) { uploadResult in
//            print("Image Upload Result: \(uploadResult)")
//        } progressHandler: { progressValue in
//            print("Image Progress: \(progressValue)")
//        }

        // working
//        Task {
//            do {
//                let (uploadedImageURL, progress) = try await FirebaseHelper.uploadImageAsync(image: .stubImage0, for: .photoMessage)
//                print("Uploaded image URL:", uploadedImageURL)
//                print("Final upload progress:", progress)
//            } catch {
//                print("Faield to upload image \(error)")
//            }
//        }
    }
}
