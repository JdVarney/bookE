//
//  EditProjectView.swift
//  bookE
//
//  Created by John on 11/10/21.
//

import SwiftUI
import CloudKit

struct EditProjectView: View {
    @ObservedObject var project: Project

    @EnvironmentObject var dataController: DataController
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("username") var username: String?

    @State private var cloudStatus = CloudStatus.checking
    @State private var showingSignIn = false
    @State private var showingNotificationsError = false
    @State private var showingDeleteConfirm = false
    @State private var title: String
    @State private var detail: String
    @State private var color: String

    @State private var remindMe: Bool
    @State private var reminderTime: Date

    @State private var cloudError: CloudError?

    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]

    enum CloudStatus {
        case checking, exists, absent
    }

    init(project: Project) {
        self.project = project

        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)

        if let projectReminderTime = project.reminderTime {
            _reminderTime = State(wrappedValue: projectReminderTime)
            _remindMe = State(wrappedValue: true)
        } else {
            _reminderTime = State(wrappedValue: Date())
            _remindMe = State(wrappedValue: false)
        }
    }

    func update() {
        project.title = title
        project.detail = detail
        project.color = color

        if remindMe {
            project.reminderTime = reminderTime

            dataController.addReminders(for: project) { success in
                if success == false {
                    project.reminderTime = nil
                    remindMe = false

                    showingNotificationsError = true
                }
            }
        } else {
            project.reminderTime = nil
            dataController.removeReminders(for: project)
        }
    }

    func delete() {
        dataController.delete(project)
        presentationMode.wrappedValue.dismiss()
    }

    func showAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    func uploadToCloud() {
        if let username = username {
            let records = project.prepareCloudRecords(owner: username)
            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            operation.savePolicy = .allKeys

            operation.modifyRecordsCompletionBlock = { _, _, error in
                if let error = error {
                    cloudError = error.getCloudKitError()
                }

                updateCloudStatus()
            }

            operation.modifyRecordsCompletionBlock = { _, _, _ in
                updateCloudStatus()
            }

            cloudStatus = .checking
            CKContainer.default().publicCloudDatabase.add(operation)
        } else {
            showingSignIn = true
        }
    }

    func updateCloudStatus() {
        project.checkCloudStatus { exists in
            if exists {
                cloudStatus = .exists
            } else {
                cloudStatus = .absent
            }
        }
    }

    func removeFromCloud() {
        let name = project.objectID.uriRepresentation().absoluteString
        let id = CKRecord.ID(recordName: name)

        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [id])

        operation.modifyRecordsCompletionBlock = { _, _, error in
            if let error = error {
                cloudError = error.getCloudKitError()
            }

            updateCloudStatus()
        }

        cloudStatus = .checking
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    var body: some View {
        Form {
            Section(header: Text("Basic settings")) {
                TextField("Project name", text: $title.onChange(update))
                TextField("Description of this project", text: $detail.onChange(update))
            }
            Section(header: Text("Custom project color")) {
                LazyVGrid(columns: colorColumns) {
                    ForEach(Project.colors, id: \.self) { item in
                        ZStack {
                            Color(item)
                                .aspectRatio(1, contentMode: .fit)
                                .cornerRadius(6)

                            if item == color {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.white)
                                    .font(.largeTitle)
                            }
                        }
                        .onTapGesture {
                            color = item
                            update()
                        }
                    }
                }
                Section(header: Text("Project reminders")) {
                    Toggle("Show reminders", isOn: $remindMe.animation().onChange(update))

                    if remindMe {
                        DatePicker(
                            "Reminder time",
                            selection: $reminderTime.onChange(update),
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
                .alert(isPresented: $showingNotificationsError) {
                    Alert(
                        title: Text("Oops!"),
                        message: Text("There was a problem. Please check you have notifications enabled."),
                        primaryButton: .default(Text("Check Settings"), action: showAppSettings),
                        secondaryButton: .cancel()
                    )
                }
                .padding(.vertical)
            }
            // swiftlint:disable line_length
            Section(footer: Text("Closing a project moves it from the Open to Closed tab; deleting it removes the project completely.")) {
                Button(project.closed ? "Reopen this project" : "Close this project") {
                    project.closed.toggle()
                    if project.closed {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                    update()
                }
            }
            Button("Delete this project") {
                showingDeleteConfirm.toggle()
            }
            .accentColor(.red)
        }
        .navigationTitle("Edit Project")
        .toolbar {
            switch cloudStatus {
            case .checking:
                ProgressView()
            case .exists:
                Button(action: removeFromCloud) {
                    Label("Remove from iCloud", systemImage: "icloud.slash")
                }
            case .absent:
                Button(action: uploadToCloud) {
                    Label("Upload to iCloud", systemImage: "icloud.and.arrow.up")
                }
            }
        }
        .alert(item: $cloudError) { error in
            Alert(
                title: Text("There was an error"),
                message: Text(error.message)
            )
        }
        .onAppear(perform: updateCloudStatus)
        .sheet(isPresented: $showingSignIn, content: SignInView.init)
        .onDisappear(perform: dataController.save)
        .alert(isPresented: $showingDeleteConfirm) {
            Alert(title: Text("Delete project?"),
                  message: Text("Are you sure you want to delete this project? " +
                                "You will also delete all the items it contains."),
                  primaryButton: .default(Text("Delete"), action: delete),
                  secondaryButton: .cancel())
        }
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: Project.example)
    }
}
