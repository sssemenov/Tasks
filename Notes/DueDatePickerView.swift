import SwiftUI

struct DueDatePicker: View {
    @Binding var selectedDate: Date?
    @Binding var isPresented: Bool
    var onClear: (() -> Void)?

    var body: some View {
        VStack { 
            DatePicker("Select Due Date", selection: Binding(
                get: { selectedDate ?? Date() },
                set: { selectedDate = $0 }
            ), displayedComponents: .date)
            .datePickerStyle(.graphical)
            .onChange(of: selectedDate) { newValue in
                isPresented = false
            }

            if selectedDate != nil {
                Button("Clear deadline") {
                    selectedDate = nil
                    isPresented = false
                    onClear?()
                }
                .foregroundColor(.red)
            }
        }
        .presentationDetents([.medium])
    }
}

struct DueDatePicker_Previews: PreviewProvider {
    @State static var selectedDate: Date? = Date()
    @State static var isPresented: Bool = true

    static var previews: some View {
        DueDatePicker(selectedDate: $selectedDate, isPresented: $isPresented, onClear: nil)
    }
}
