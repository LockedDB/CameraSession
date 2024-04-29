//
//  CameraOverlay.swift
//  CameraSession
//
//  Created by Dani Benet on 29/4/24.
//

import SwiftUI

struct CameraOverlay: View {
    var body: some View {
        ZStack {
            CameraGrid()
            VStack {
                Spacer()
                CameraButton()
                    .padding(.bottom)
            }
        }
    }
}

struct CameraButton: View {
    var body: some View {
        ZStack {
            Circle().stroke(Color.white, lineWidth: 3).frame(width: 72)
            Circle().frame(width: 64)
        }
    }
}

struct CameraGrid: View {
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Rectangle().frame(width: 1).opacity(0.2)
                Spacer()
                Rectangle().frame(width: 1).opacity(0.2)
                Spacer()
            }
            
            VStack {
                Spacer()
                Rectangle().frame(height: 1).opacity(0.2)
                Spacer()
                Rectangle().frame(height: 1).opacity(0.2)
                Spacer()
            }
        }
    }
}

#Preview {
    VStack {
        CameraOverlay()
            .preferredColorScheme(.dark)
    }
}
