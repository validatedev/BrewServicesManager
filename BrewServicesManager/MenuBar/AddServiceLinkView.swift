//
//  AddServiceLinkView.swift
//  BrewServicesManager
//

import SwiftUI

struct AddServiceLinkView: View {
    let serviceName: String
    let onSave: (URL, String?) -> Void
    let onCancel: () -> Void

    @State private var urlString = ""
    @State private var label = ""
    @FocusState private var urlFieldFocused: Bool

    private var isValid: Bool {
        guard let url = URL(string: urlString),
              let scheme = url.scheme?.lowercased() else {
            return false
        }

        // Block potentially malicious schemes - allow everything else
        let blockedSchemes = ["javascript", "data", "file"]

        return !blockedSchemes.contains(scheme)
    }

    var body: some View {
        VStack(spacing: .zero) {
            PanelHeaderView(title: "Add Link", onBack: onCancel)

            Divider()

            VStack(alignment: .leading, spacing: LayoutConstants.compactPadding) {
                Text("Add link for \(serviceName)")
                    .font(.headline)

                VStack(alignment: .leading, spacing: LayoutConstants.tightSpacing) {
                    Text("URL")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("http://localhost:8080", text: $urlString)
                        .textFieldStyle(.roundedBorder)
                        .focused($urlFieldFocused)
                }

                VStack(alignment: .leading, spacing: LayoutConstants.tightSpacing) {
                    Text("Label (optional)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("My Service", text: $label)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Spacer()

                    Button("Cancel") {
                        onCancel()
                    }
                    .keyboardShortcut(.cancelAction)

                    Button("Add") {
                        if let url = URL(string: urlString) {
                            let trimmedLabel = label.trimmingCharacters(in: .whitespaces)
                            onSave(url, trimmedLabel.isEmpty ? nil : trimmedLabel)
                        }
                    }
                    .disabled(!isValid)
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, LayoutConstants.compactPadding)
            }
            .padding()

            Spacer()
        }
        .onAppear {
            urlFieldFocused = true
        }
    }
}
