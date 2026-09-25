//
//  SidebarButtonView.swift
//  Sidekick
//
//  Created by John Bean on 2/20/25.
//

import SwiftUI

struct SidebarButtonView: View {
	
	@State private var isHovering: Bool = false
	
	var title: String
	var systemImage: String
	
	var action: () -> Void
	
	var buttonOpacity: Double {
		return self.isHovering ? 0.12 : 0
	}
	
	var body: some View {
		Button {
			self.action()
		} label: {
			Label(
				title,
				systemImage: systemImage
			)
			.foregroundStyle(.primary)
			.font(.callout.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .leading)
			.padding(.horizontal, 10)
			.padding(.vertical, 9)
			.background(
				Color.gray.opacity(self.buttonOpacity)
			)
			.clipShape(
				InterfaceStyle.roundedRectangle
			)
		}
		.buttonStyle(.plain)
		.onHover { hovering in
			withAnimation(
				.linear(duration: 0.3)
			) {
				self.isHovering = hovering
			}
		}
	}
	
}
