//
//  ContentView.swift
//  CameraSession
//
//  Created by Dani Benet on 16/4/24.
//

import SwiftUI

struct ContentView: View {
    var cameraVM = CameraVM()
    @State private var showDebugSettings = false
    
    var body: some View {
        VStack {
            CameraPreview(session: cameraVM.session)
                .overlay {
                    CameraOverlay()
                }
        }
        .overlay {
            if case .failed(let error) = cameraVM.cameraManager.status {
                ContentUnavailableView {
                    Label(error.info.label, systemImage: error.info.systemImage)
                } description: {
                    Text("\(error.localizedDescription)")
                    if error == CameraError.permissionDenied {
                        Button("Open Settings") {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }
                    }
                }
            }
        }
        .gesture(MagnificationGesture().onEnded { _ in
            self.showDebugSettings.toggle()
        })
        .sheet(isPresented: $showDebugSettings) {
            VStack {
                List(cameraVM.cameraManager.availableInputDevices, id: \.uniqueID) { device in
                    Text(device.localizedName)
                        .onTapGesture {
                            cameraVM.changeInputDevice(device: device)
                            self.showDebugSettings.toggle()
                        }
                }
            }
        }
        .onAppear {
            cameraVM.checkForDevicePermissions()
        }
    }
}
