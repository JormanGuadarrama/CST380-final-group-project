//
//  UserDeal.swift
//  LocalDeals
//
//  Created by Kevin Crapo on 4/26/26.
//


import Foundation

struct UserDeal: Identifiable, Hashable {
    let id: String
    let userId: String
    let dealId: String
    let relationType: String
    let createdAt: Date?
}