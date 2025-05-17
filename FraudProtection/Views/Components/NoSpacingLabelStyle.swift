struct NoSpacingLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) { // 👈 zero spacing
            configuration.icon
            configuration.title
        }
    }
}
