//
//  ContentView.swift
//  CameraSession
//
//  Created by Dani Benet on 16/4/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var cameraVM = CameraVM()
    
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
        .onAppear {
            cameraVM.checkForDevicePermissions()
        }
    }
}
