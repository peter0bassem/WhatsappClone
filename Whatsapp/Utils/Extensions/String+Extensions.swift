//
//  String+Extensions.swift
//  Whatsapp
//
//  Created by iCommunity app on 24/08/2024.
//

import Foundation

extension String {
    var isEmptyOrWhiteSpace: Bool { return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}

extension String? {
    var removeOptional: String { self ?? "" }
}
