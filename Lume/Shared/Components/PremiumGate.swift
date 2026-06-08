//  Akshay Shukla
//  PremiumGate.swift
//  Lume
//
//  Monetization gate (Option A — stub always unlocked).
//  To activate StoreKit 2, swap LumeStore.isUnlocked(_:) for a real
//  Transaction.currentEntitlements check. No callsites change.
//

import SwiftUI

// MARK: - LumeStore (Option A stub)

/// Singleton that answers entitlement checks.
/// Currently always returns `true` (Option A).
/// Replace the body of `isUnlocked(_:)` when StoreKit 2 is wired up.
final class LumeStore {
    static let shared = LumeStore()
    private init() {}

    func isUnlocked(_ feature: PremiumFeatureID) -> Bool {
        // Option A: all content is free.
        // Option B: return purchasedProductIDs.contains(feature.productID)
        return true
    }
}

// MARK: - PremiumGate View

/// Wraps any SwiftUI view with a premium check.
/// Shows content if unlocked; shows LockedOverlay if not.
///
/// Usage:
///   PremiumGate(feature: .flipClock) {
///       FlipClock(...)
///   }
struct PremiumGate<Content: View>: View {
    let feature: PremiumFeatureID
    @ViewBuilder let content: () -> Content

    var body: some View {
        if LumeStore.shared.isUnlocked(feature) {
            content()
        } else {
            LockedThemeOverlay(feature: feature)
        }
    }
}

// MARK: - Locked Overlay

/// Shown in place of premium content when not unlocked.
struct LockedThemeOverlay: View {
    let feature: PremiumFeatureID

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)

            VStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.secondary)

                Text("Premium")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        )
    }
}
