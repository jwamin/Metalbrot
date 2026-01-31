//
//  RendererViewModel.swift
//  Metalbrot
//
//  Created by Joss Manger on 5/6/23.
//

import Foundation
import simd
import Combine

protocol MetalbrotViewModelInterface: AnyObject {
    
    //Monstrous @Published Protocol Adapter
    var zoomLevel: CGFloat { get }
    var zoomLevelPublished: Published<CGFloat> { get }
    var zoomLevelPublisher: Published<CGFloat>.Publisher { get }
    
    //Monstrous @Published Protocol Adapter
    var center: CGPoint { get }
    var centerPublished: Published<CGPoint> { get }
    var centerPublisher: Published<CGPoint>.Publisher { get }
    
    func updateCenter(_ newPoint: CGPoint)
    func updateZoom(_ newZoomLevel: CGFloat)
    func setZoom(_ newZoomLevel: CGFloat)
    func applyZoom(delta: CGFloat, focus: CGPoint, viewSize: CGSize)
    func applyZoom(scaleFactor: CGFloat, focus: CGPoint, viewSize: CGSize)
    func startZoomInertia(deltaVelocity: CGFloat, focus: CGPoint, viewSize: CGSize)
    func startZoomInertia(scaleVelocity: CGFloat, focus: CGPoint, viewSize: CGSize)
    func stopZoomInertia()
    
    func requestUpdate()
    
    func getAdjustedRect(viewSize: vector_uint2) -> (vector_int2, vector_float2)
    
    // Color scheme support
    var selectedColorScheme: UInt32 { get }
    var selectedColorSchemePublished: Published<UInt32> { get }
    var selectedColorSchemePublisher: Published<UInt32>.Publisher { get }
    
    func setColorScheme(_ scheme: UInt32)
    func cycleColorScheme()
    
}


final class MetalbrotRendererViewModel: MetalbrotViewModelInterface {

    //MetalbrotViewModelInterface protocol conformance
    var zoomLevel: CGFloat { zoomLevelConcretePublished }
    var zoomLevelPublished: Published<CGFloat> { _zoomLevelConcretePublished }
    var zoomLevelPublisher: Published<CGFloat>.Publisher { $zoomLevelConcretePublished }
    
    var center: CGPoint { centerConcretePublished }
    var centerPublished: Published<CGPoint> { _centerConcretePublished }
    var centerPublisher: Published<CGPoint>.Publisher { $centerConcretePublished }
    
    var selectedColorScheme: UInt32 { selectedColorSchemeConcretePublished }
    var selectedColorSchemePublished: Published<UInt32> { _selectedColorSchemeConcretePublished }
    var selectedColorSchemePublisher: Published<UInt32>.Publisher { $selectedColorSchemeConcretePublished }
    
    //GET
    func getAdjustedRect(viewSize: vector_uint2) -> (vector_int2, vector_float2) {
        
        let signed_vector = vector_float2(Float(viewSize.x), Float(viewSize.y))
        let fixedZoomLevel = zoomLevel == 0 ? 1 : Float(zoomLevel)
        let newSize = signed_vector * fixedZoomLevel
        
        let xWidth = Int32(viewSize.x / 2)
        let yHeight = Int32(viewSize.y / 2)
        let xWidthN = Int32(newSize.x / 2)
        let yHeightN = Int32(newSize.y / 2)
        let x = Int32(center.x) + xWidth - xWidthN
        let y = Int32(center.y) + yHeight - yHeightN
        return ([x , y], [newSize.x, newSize.y])
    }
    
    //SET
    func updateCenter(_ newPoint: CGPoint){
        centerConcretePublished = newPoint
    }
    
    func updateZoom(_ newZoomLevel: CGFloat){
        zoomLevelConcretePublished += newZoomLevel
    }
    
    func setZoom(_ newZoomLevel: CGFloat){
        zoomLevelConcretePublished = newZoomLevel
    }
    
    func applyZoom(scaleFactor: CGFloat, focus: CGPoint, viewSize: CGSize) {
        let effectiveSpeed = zoomSpeedForLevel(zoomLevelConcretePublished)
        let safeScale = max(scaleFactor, 0.0001)
        let delta = log(safeScale) / effectiveSpeed
        applyZoom(delta: delta, focus: focus, viewSize: viewSize)
    }
    
    func applyZoom(delta: CGFloat, focus: CGPoint, viewSize: CGSize) {
        guard viewSize.width > 0, viewSize.height > 0 else {
            return
        }
        let effectiveSpeed = zoomSpeedForLevel(zoomLevelConcretePublished)
        let factor = exp(delta * effectiveSpeed)
        let oldZoom = max(zoomLevelConcretePublished, 0.0001)
        let newZoom = min(max(oldZoom * factor, 0.0001), 1000)
        
        let oldZoomSize = CGSize(width: viewSize.width * oldZoom, height: viewSize.height * oldZoom)
        let newZoomSize = CGSize(width: viewSize.width * newZoom, height: viewSize.height * newZoom)
        
        let oldOrigin = CGPoint(
            x: centerConcretePublished.x + (viewSize.width / 2) - (oldZoomSize.width / 2),
            y: centerConcretePublished.y + (viewSize.height / 2) - (oldZoomSize.height / 2)
        )
        
        let focusNorm = CGPoint(x: focus.x / viewSize.width, y: focus.y / viewSize.height)
        let worldPoint = CGPoint(
            x: oldOrigin.x + (focusNorm.x * oldZoomSize.width),
            y: oldOrigin.y + (focusNorm.y * oldZoomSize.height)
        )
        
        let newOrigin = CGPoint(
            x: worldPoint.x - (focusNorm.x * newZoomSize.width),
            y: worldPoint.y - (focusNorm.y * newZoomSize.height)
        )
        
        let newCenter = CGPoint(
            x: newOrigin.x - (viewSize.width / 2) + (newZoomSize.width / 2),
            y: newOrigin.y - (viewSize.height / 2) + (newZoomSize.height / 2)
        )
        
        zoomLevelConcretePublished = newZoom
        centerConcretePublished = newCenter
        
        zoomInertiaFocus = focus
        zoomInertiaViewSize = viewSize
    }
    
    func startZoomInertia(deltaVelocity: CGFloat, focus: CGPoint, viewSize: CGSize) {
        guard viewSize.width > 0, viewSize.height > 0 else {
            return
        }
        stopZoomInertia()
        zoomInertiaSpeed = zoomSpeedForLevel(zoomLevelConcretePublished)
        zoomInertiaVelocity = deltaVelocity
        zoomInertiaFocus = focus
        zoomInertiaViewSize = viewSize
        lastInertiaTick = CFAbsoluteTimeGetCurrent()
        
        zoomInertiaTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let now = CFAbsoluteTimeGetCurrent()
            let dt = max(now - self.lastInertiaTick, 0)
            self.lastInertiaTick = now
            
            if abs(self.zoomInertiaVelocity) < self.zoomInertiaMinVelocity {
                self.stopZoomInertia()
                return
            }
            
            let delta = self.zoomInertiaVelocity * dt
            self.applyZoom(delta: delta, focus: self.zoomInertiaFocus, viewSize: self.zoomInertiaViewSize)
            self.zoomInertiaVelocity *= exp(-self.zoomInertiaDamping * dt)
        }
        RunLoop.main.add(zoomInertiaTimer!, forMode: .common)
    }
    
    func startZoomInertia(scaleVelocity: CGFloat, focus: CGPoint, viewSize: CGSize) {
        let deltaVelocity = scaleVelocity / max(zoomInertiaSpeed, 0.0001)
        startZoomInertia(deltaVelocity: deltaVelocity, focus: focus, viewSize: viewSize)
    }
    
    func stopZoomInertia() {
        zoomInertiaTimer?.invalidate()
        zoomInertiaTimer = nil
        zoomInertiaVelocity = 0
    }
    
    func setColorScheme(_ scheme: UInt32) {
        print("Color scheme changed from \(selectedColorSchemeConcretePublished) to \(scheme)")
        selectedColorSchemeConcretePublished = scheme
    }
    
    func cycleColorScheme() {
        let currentScheme = selectedColorSchemeConcretePublished
        let nextScheme = (currentScheme + 1) % colorSchemeCount
        print("Cycling color scheme from \(currentScheme) to \(nextScheme)")
        selectedColorSchemeConcretePublished = nextScheme
    }
    
    func requestUpdate() {
        let concrete = zoomLevel
        zoomLevelConcretePublished = concrete
    }
    
    //Concrete Implementation
    @Published private var zoomLevelConcretePublished: CGFloat
    @Published private var centerConcretePublished: CGPoint
    @Published private var selectedColorSchemeConcretePublished: UInt32
    
    private let colorSchemeCount: UInt32 = 10
    
    private let zoomSpeed: CGFloat
    private let zoomSpeedMinFactor: CGFloat = 0.05
    private let zoomSpeedMaxFactor: CGFloat = 2.0
    private let zoomInertiaDamping: CGFloat = 6.0
    private let zoomInertiaMinVelocity: CGFloat = 5.0
    private var zoomInertiaVelocity: CGFloat = 0
    private var zoomInertiaFocus: CGPoint = .zero
    private var zoomInertiaViewSize: CGSize = .zero
    private var zoomInertiaTimer: Timer?
    private var zoomInertiaSpeed: CGFloat = 0
    private var lastInertiaTick: CFAbsoluteTime = 0
    
    init(){
        #if os(macOS)
        zoomSpeed = 0.0035
        #else
        zoomSpeed = 0.0020
        #endif
        zoomLevelConcretePublished = 1
        centerConcretePublished = .zero
        selectedColorSchemeConcretePublished = 0 // Default to rainbow scheme
    }
    
    private func zoomSpeedForLevel(_ level: CGFloat) -> CGFloat {
        let clamped = min(max(level, zoomSpeedMinFactor), zoomSpeedMaxFactor)
        return zoomSpeed * clamped
    }
    
}
