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
                .ignoresSafeArea(edges: .all)
        }
        .onAppear {
            cameraVM.checkForDevicePermissions()
        }
    }
}
