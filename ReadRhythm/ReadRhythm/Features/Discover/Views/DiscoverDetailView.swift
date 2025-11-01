import SwiftUI

struct DiscoverDetailView: View {
    let detail: DiscoverBookDetail
    @State private var showFullDescription: Bool = false

    private let coverSize = CGSize(width: 180, height: 260)

    // `DiscoverBookDetail` does not expose `infoLink`; prefer previewLink if available.
    private var externalURL: URL? {
        return detail.previewLink
    }

    /// Extract a 4-digit year from `publishedDate` (YYYY, YYYY-MM, YYYY-MM-DD).
    private var publishedYear: String? {
        guard let raw = detail.publishedDate, !raw.isEmpty else { return nil }
        let year = raw.prefix(4)
        return year.count == 4 ? String(year) : nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace._24) {
                coverSection
                metaSection
                if let description = detail.description, !description.isEmpty {
                    descriptionSection(description)
                }
                if let url = externalURL {
                    googleBooksLink(url)
                }
            }
            .padding(.horizontal, AppSpace._16)
            .padding(.vertical, AppSpace._24)
        }
        .screenBackground()
        .navigationTitle(Text(LocalizedStringKey("discover.detail.title")))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("discover.detail")
    }

    // MARK: - Sections

    private var coverSection: some View {
        VStack(alignment: .center) {
            coverImage
        }
        .frame(maxWidth: .infinity)
    }

    private var metaSection: some View {
        VStack(alignment: .leading, spacing: AppSpace._12) {
            VStack(alignment: .leading, spacing: AppSpace._6) {
                Text(detail.title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(AppColors.Semantic.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if let subtitle = detail.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.headline)
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if !detail.authorsDisplay.isEmpty {
                Label {
                    Text(detail.authorsDisplay)
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                } icon: {
                    Image(systemName: "person.2")
                }
                .font(.subheadline)
                .accessibilityLabel(Text(String(format: String(localized: String.LocalizationValue("discover.detail.authors.accessibility")), detail.authorsDisplay)))
            }

            VStack(alignment: .leading, spacing: AppSpace._8) {
                if let publisher = detail.publisher, !publisher.isEmpty {
                    infoRow(systemImage: "building.2", labelKey: "discover.detail.publisher", value: publisher)
                }
                if let year = publishedYear {
                    infoRow(systemImage: "calendar", labelKey: "discover.detail.publishedDate", value: year)
                }
                if let pages = detail.pageCount {
                    infoRow(systemImage: "book", labelKey: "discover.detail.pageCount", value: String(pages))
                }
            }

            if !detail.categories.isEmpty {
                VStack(alignment: .leading, spacing: AppSpace._8) {
                    Text(LocalizedStringKey("discover.detail.categories"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.Semantic.textPrimary)
                    WrappingChips(detail.categories) { category in
                        Text(category)
                            .font(.caption)
                            .padding(.vertical, 6)
                            .padding(.horizontal, AppSpace._12)
                            .background(AppColors.Semantic.bgElevated)
                            .clipShape(Capsule(style: .continuous))
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
                            )
                    }
                }
            }
        }
    }

    private func descriptionSection(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpace._8) {
            Text(LocalizedStringKey("discover.detail.about"))
                .font(.headline)
                .foregroundStyle(AppColors.Semantic.textPrimary)
            Text(text)
                .font(.body)
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .lineLimit(showFullDescription ? nil : 6)
            Button(showFullDescription ? String(localized: "detail.readLess") : String(localized: "detail.readMore")) {
                showFullDescription.toggle()
            }
            .buttonStyle(.plain)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(AppColors.Semantic.tintPrimary)
            .accessibilityIdentifier("discover.detail.description.toggle")
        }
    }

    private func googleBooksLink(_ url: URL) -> some View {
        Link(destination: url) {
            Text(LocalizedStringKey("discover.detail.openGoogleBooks"))
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpace._12)
                .background(AppColors.Semantic.tintPrimary)
                .foregroundStyle(AppColors.Semantic.textInverse)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous))
        }
        .accessibilityIdentifier("discover.detail.openLink")
    }

    // MARK: - Subviews

    private var coverImage: some View {
        Group {
            if let url = detail.thumbnailURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderCover
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: coverSize.width, height: coverSize.height)
                            .clipped()
                    case .failure:
                        placeholderCover
                    @unknown default:
                        placeholderCover
                    }
                }
            } else {
                placeholderCover
            }
        }
        .frame(width: coverSize.width, height: coverSize.height)
        .cornerRadius(AppRadius.l)
        .shadow(color: AppShadow.elevation1, radius: 4, x: 0, y: 2)
        .accessibilityHidden(true)
    }

    private var placeholderCover: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous)
                .fill(AppColors.Semantic.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous)
                        .stroke(AppColors.Semantic.borderMuted, lineWidth: 1)
                )
            Text(initials(from: detail.title))
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(AppColors.Semantic.tintPrimary.opacity(0.8))
        }
        .frame(width: coverSize.width, height: coverSize.height)
    }

    private func initials(from text: String) -> String {
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let initials = words.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }

    private func infoRow(systemImage: String, labelKey: String, value: String) -> some View {
        HStack(spacing: AppSpace._8) {
            Image(systemName: systemImage)
            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(labelKey))
                    .font(.caption)
                    .foregroundStyle(AppColors.Semantic.textSecondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.Semantic.textPrimary)
            }
        }
        .accessibilityLabel(Text("\(String(localized: String.LocalizationValue(labelKey))). \(value)"))
    }
}

// MARK: - Wrapping Chips Helper

private struct WrappingChips<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    private let data: Data
    private let content: (Data.Element) -> Content
    private let spacing: CGFloat

    @State private var totalHeight: CGFloat = .zero

    init(_ data: Data, spacing: CGFloat = AppSpace._8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            generateContent(in: geometry)
        }
        .frame(minHeight: totalHeight)
    }

    private func heightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry -> Color in
            DispatchQueue.main.async {
                binding.wrappedValue = geometry.size.height
            }
            return Color.clear
        }
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        let items = Array(data)

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { element in
                content(element)
                    .alignmentGuide(.leading) { dimension in
                        if width + dimension.width > geometry.size.width {
                            width = 0
                            height -= dimension.height + spacing
                        }
                        let result = width
                        width += dimension.width + spacing
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if element == items.last {
                            width = 0
                        }
                        return result
                    }
            }
        }
        .background(heightReader($totalHeight))
    }
}
