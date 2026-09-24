//
//  MessageBackgroundView.swift
//  Sidekick
//
//  Created by Bean John on 10/23/24.
//

import SwiftUI

struct MessageBackgroundView: View {
	
	private let cornerRadius: CGFloat = 12
	
	var body: some View {
		RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
			.fill(Color(nsColor: .controlBackgroundColor))
			.overlay {
				RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
					.strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
			}
	}
	
}

#Preview {
    MessageBackgroundView()
}
