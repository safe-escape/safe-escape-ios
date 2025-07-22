//
//  IntroView.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/16/25.
//

import SwiftUI

struct IntroView: View {
    // 인트로 뷰 show/hide
    @Binding var show: Bool
    
    // 로고 이미지 애니메이션
    @State var logoAnimationCount: Int = 0
    @State var bounce: Bool = false
    
    // 슬로건 애니메이션
    @State var showSloagan: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            // 로고
            Image(.logo)
                .offset(y: bounce ? -40 : 0)
            
            // 슬로건
            Image(.slogan)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
                .padding(.top, 25)
                .padding(.leading, 5)
                .opacity(showSloagan ? 1 : 0)
                .animation(.easeInOut, value: showSloagan)
                .padding(.bottom, 150)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .onAppear {
            bounceLogo()
        }
        .onChange(of: logoAnimationCount) { count in
            // 로고 애니메이션은 2번만 반복 이후엔 슬로건 보여주고 인트로 종료
            guard count < 2 else {
                showSloagan = true
                
                dismiss()
                
                return
            }
            
            bounceLogo()
        }
    }
    
    // 로고 이미지 애니메이션
    func bounceLogo() {
        Task {
            try? await Task.sleep(for: .seconds(0.3))
            withAnimation(.interpolatingSpring(mass: 1.1, stiffness: 120, damping: 5)) {
                bounce = true
            }
            
            try? await Task.sleep(for: .seconds(0.45))
            withAnimation(.interpolatingSpring(mass: 1.2, stiffness: 160, damping: logoAnimationCount < 1 ? 7 : 14)) {
                bounce = false
            }
            
            try? await Task.sleep(for: .seconds(logoAnimationCount < 1 ? 0.7 : 0.8))
            logoAnimationCount += 1
        }
    }
    
    // 인트로 종료
    func dismiss() {
        withAnimation(.easeInOut(duration: 0.2).delay(0.9)) {
            show = false
        }
    }
}

#Preview {
    IntroView(show: .constant(true))
}
