//
//  DealDetailView.swift
//  LocalDeals
//
//  Detail card layout showing store name, discount, and expiration.
//

import SwiftUI

struct DealDetailView: View {
    let deal: Deal

    @Environment(DealManager.self) var dealManager
    @Environment(AuthManager.self) var authManager

    private var currentDeal: Deal {
        dealManager.deals.first(where: { $0.id == deal.id }) ?? deal
    }

    private var formattedExpiration: String {
        currentDeal.expiration.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text(currentDeal.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Label(currentDeal.businessName, systemImage: "storefront")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color.accentColor.opacity(0.12))

                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        InfoPill(icon: "tag", text: currentDeal.discountType)
                        InfoPill(icon: "clock", text: formattedExpiration)
                        InfoPill(icon: "location", text: "— mi")
                    }

                    Text("Details")
                        .font(.headline)

                    Text(currentDeal.description.isEmpty ? "No additional details." : currentDeal.description)
                        .font(.body)

                    Text("Posted by: \(currentDeal.createdByEmail ?? "Unknown")")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    DealVoteControls(deal: currentDeal)
                        .padding(.vertical, 4)

                    Button {
                        guard let userID = authManager.userID else { return }

                        Task {
                            await dealManager.toggleSave(deal: currentDeal, userID: userID)
                        }
                    } label: {
                        Label(
                            dealManager.isSaved(currentDeal) ? "Remove Saved Deal" : "Save Deal",
                            systemImage: dealManager.isSaved(currentDeal) ? "bookmark.fill" : "bookmark"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundColor(.accentColor)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Deal Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct InfoPill: View {
    let icon: String
    let text: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .cornerRadius(20)
    }
}

struct DealVoteControls: View {
    let deal: Deal
    var compact: Bool = false

    @Environment(DealManager.self) private var dealManager
    @Environment(AuthManager.self) private var authManager

    private var currentVote: Int? {
        dealManager.currentUserVote(for: deal.id)
    }

    private var canVote: Bool {
        authManager.userID != nil
    }

    private var scoreFont: Font {
        compact ? .headline : .largeTitle.bold()
    }

    private var scoreLabelFont: Font {
        compact ? .caption2 : .caption
    }

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 10) {
            HStack(spacing: compact ? 8 : 14) {
                voteButton(value: 1, systemImage: "hand.thumbsup", selectedTint: .green)

                VStack(spacing: 2) {
                    Text("\(deal.votes)")
                        .font(scoreFont)
                        .fontWeight(.bold)
                        .monospacedDigit()

                    Text("score")
                        .font(scoreLabelFont)
                        .foregroundStyle(.secondary)
                }
                .frame(minWidth: compact ? 48 : 72)

                voteButton(value: -1, systemImage: "hand.thumbsdown", selectedTint: .red)
            }

            if !compact {
                Text(canVote ? "Tap again on a selected vote to remove it." : "Sign in to vote on this deal.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func voteButton(value: Int, systemImage: String, selectedTint: Color) -> some View {
        let isSelected = currentVote == value

        return Button {
            guard let userID = authManager.userID else { return }

            Task {
                await dealManager.vote(on: deal, desiredValue: value, userID: userID)
            }
        } label: {
            Image(systemName: isSelected ? "\(systemImage).fill" : systemImage)
                .font(compact ? .headline : .title3)
                .frame(width: compact ? 40 : 48, height: compact ? 40 : 48)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isSelected ? selectedTint.opacity(0.18) : Color(.systemGray6))
                )
                .foregroundStyle(isSelected ? selectedTint : .primary)
        }
        .buttonStyle(.plain)
        .disabled(!canVote)
        .opacity(canVote ? 1 : 0.6)
        .accessibilityLabel(value == 1 ? "Upvote" : "Downvote")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}

#Preview {
    NavigationStack {
        DealDetailView(deal: Deal.mockedDeals[0])
            .environment(DealManager(isMocked: true))
            .environment(AuthManager(isMocked: true))
    }
}
