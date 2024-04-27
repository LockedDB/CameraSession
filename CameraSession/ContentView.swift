//
//  ContentView.swift
//  CameraSession
//
//  Created by Dani Benet on 16/4/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var cameraVM = CameraVM()
    @State private var showDebugSettings = false
    
    var body: some View {
        VStack {
            CameraPreview(session: cameraVM.session)
                .overlay {
                    if case .failed(let error) = cameraVM.cameraManager.status {
                        ContentUnavailableView {
                            Label("No Device", systemImage: "iphone.rear.camera")
                        } description: {
                            Text("\(error.localizedDescription)")
                        }
                    }
                }
                .ignoresSafeArea(edges: .all)
        }
        .gesture(MagnificationGesture().onEnded { _ in
            self.showDebugSettings.toggle()
        })
        .sheet(isPresented: $showDebugSettings) {
            VStack {
                List(cameraVM.cameraManager.availableDevices, id: \.uniqueID) { device in
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
