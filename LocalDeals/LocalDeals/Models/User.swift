//
//  User.swift
//  LocalDeals
//
//  Created by Kevin Crapo on 4/26/26.
//


import Foundation
import FirebaseFirestore

struct User: Identifiable, Hashable {
    let id: String
    let email: String
    let username: String
    let displayName: String
    let photoURL: String
    let provider: String
    let createdAt: Date?
    let lastLoginAt: Date?
}