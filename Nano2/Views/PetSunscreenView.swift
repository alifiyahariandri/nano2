import SwiftUI

struct Line {
    var points = [CGPoint]()
    var color: Color = .white
    var lineWidth: Double = 100.0
}

struct PetSunscreenView: View {
    @Binding var isSunscreen: Bool

    @State var touchedAreaPercentage: Double = 0
    
    @State private var currentLine = Line()
    @State private var lines: [Line] = []
    @State private var thickness: Double = 100.0
    @State private var isDrawingAllowed: Bool = true
    @State private var showAlert: Bool = false
    
    @State var imageName: String = "chara2"
    
    var body: some View {
        VStack {
            Image(imageName)
                .animation(.bouncy)
                .padding(50)
                .overlay(
                    Canvas { context, _ in
                        for line in lines {
                            var path = Path()
                            path.addLines(line.points)
                            context.stroke(path, with: .color(line.color.opacity(0.03)), lineWidth: line.lineWidth)
                        }
                    }
                    .clipShape(SVGPath())
                )
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            guard isDrawingAllowed else { return }
                            
                            let newPoint = value.location
                            currentLine.points.append(newPoint)
                            self.lines.append(currentLine)
                            // Calculate the percentage of the touched area
                            self.touchedAreaPercentage = calculateTouchedAreaPercentage(canvasSize: CGSize(width: 200, height: 200))
                            print("Touched Area Percentage: \(touchedAreaPercentage)%")
                            
                            self.imageName = "chara3"
                            
                            if self.touchedAreaPercentage > 25 {
                                print("HORE UDAH")
                                isDrawingAllowed = false
                                showAlert = true
                                clearDrawing()
                            }
                        }
                        .onEnded { _ in
                            self.imageName = "chara2"

                            guard isDrawingAllowed else { return }
                            
                            self.lines.append(currentLine)
                            self.currentLine = Line(points: [], color: currentLine.color, lineWidth: thickness)
                            
                            if self.touchedAreaPercentage > 5 {
                                print("HORE UDAH")
                                isDrawingAllowed = false
                                showAlert = true
                                clearDrawing()
                            }
                        }
                )
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Success"),
                        message: Text("Touched area percentage exceeded 25%"),
                        dismissButton: .default(Text("OK")) {
                            isSunscreen = false
                        }
                    )
                }
        }
    }
    
    // Function to calculate the touched area percentage
    func calculateTouchedAreaPercentage(canvasSize: CGSize) -> Double {
        // Calculate the total pixels on the canvas
        let totalPixels = Int(canvasSize.width * canvasSize.height)
        // Calculate the number of points in all lines
        var touchedPixels = 0
        for line in lines {
            touchedPixels += line.points.count
        }
        // Calculate the percentage of the area that has been touched
        let touchedAreaPercentage = Double(touchedPixels) / Double(totalPixels) * 100.0
        return touchedAreaPercentage
    }
    
    // Function to clear the drawing
    func clearDrawing() {
        lines = []
    }
}

struct SVGPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addEllipse(in: rect, transform: CGAffineTransform(scaleX: 1, y: 1.25))
    
        path.closeSubpath()
        return path
    }
}

