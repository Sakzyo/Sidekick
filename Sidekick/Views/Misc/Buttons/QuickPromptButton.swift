//
//  QuickPromptButton.swift
//  Sidekick
//
//  Created by John Bean on 3/15/25.
//

import SwiftUI

struct QuickPromptButton: View {
	
	@Binding var input: String
	@State private var isHovered: Bool = false
	
	var prompt: QuickPrompt
	
	var body: some View {
		Button {
			withAnimation(.linear) {
				self.input = self.prompt.text
            }
		} label: {
			prompt.label
				.saturation(0)
				.font(.callout)
				.padding(.vertical, 8)
				.padding(.horizontal, 12)
				.frame(
					maxWidth: .infinity,
					alignment: .leading
				)
				.background {
					InterfaceStyle.chatButtonShape
						.fill(Color(nsColor: .controlBackgroundColor).opacity(isHovered ? 1 : 0.6))
				}
				.overlay {
					InterfaceStyle.chatButtonShape
						.strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
				}
		}
		.buttonStyle(.plain)
		.onHover { isHovered = $0 }
		.frame(maxWidth: 300)
	}
	
}
