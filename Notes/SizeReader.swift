import SwiftUI

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

public struct SizeReaderModifier: ViewModifier {

    @Binding private var size: CGSize

    init(size: Binding<CGSize>) {
        _size = size
    }
    public func body(content: Content) -> some View {
        content
            .onSizeChange { size in
                self.size = size
            }
    }
}

public extension View {

    func onSizeChange(size: Binding<CGSize>) -> some View {
        modifier(SizeReaderModifier(size: size))
    }

    func onSizeChange(_ onChange: @escaping (CGSize) -> Void) -> some View {
        notifySizeChange()
            .onSizeChangeNotification(onChange)
    }

    func onSizeChangeNotification(_ onChange: @escaping (CGSize) -> Void) -> some View {
        onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }

    func notifySizeChange() -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
            }
        )
    }
}
