//: PI Playground - noun: a place where people can play with PI
// Sean Alling
// Available the MIT Open License

import Cocoa
import Foundation

var str = "Hello, Welcome to THE awesome Monte Carlo playground for PI"

/*:
This playground estimates the value of PI based on Monte Carlo methods. A random point is generated within a square. That point's distance from the center of the Square is then calculated and compared to the radius of the Circle which inscribes that Square. If the random point is inside that inscribed Circle, it is tallied. Then using a simple formula shown below, PI is an estimation of the weighted ratio of the tally of points inside the circle by 4 and the total number of generated points. These estimation vary for each trial because the generated points are psuedorandom. Feel free to experiment with the 'Experiment' struct and see how the number of trials and the number of points effect the overall and individual estimation of PI.

    Enjoy!
*/

struct Random {
    static func within<B: protocol<Comparable, ForwardIndexType>>(range: ClosedInterval<B>) -> B {
        let inclusiveDistance = range.start.distanceTo(range.end).successor()
        let randomAdvance = B.Distance(arc4random_uniform(UInt32(inclusiveDistance.toIntMax())).toIntMax())
        return range.start.advancedBy(randomAdvance)
    }
    
    static func within(range: ClosedInterval<Double>) -> Double {
        return (range.end - range.start) * Double(Double(arc4random()) / Double(UInt32.max)) + range.start
    }
    
    static func generate() -> Double {
        return Random.within(0.0...1.0)
    }
}


struct Point {
    
    let x: Double
    let y: Double
}

class Circle {
    
    let center: Point
    let radius: Double
    
    init(center: Point, radius: Double) {
        
        self.center = center
        self.radius = radius
    }
    
    func isInsideMe(inputPoint: Point) -> Bool {
        
        let distanceFromCenter = sqrt( pow((inputPoint.x - self.center.x), 2) + pow((inputPoint.y - self.center.y), 2) )
        
        if (distanceFromCenter <= self.radius) {
            
            return true
            
        } else {
            
            return false
        }
    }
    
    
}


class Square {
    
    let center: Point
    let side: Double
    
    init(center: Point, side: Double) {
        
        self.center = center
        self.side = side
    }
    
    func createInscribedCircle() -> Circle {
        
        let newCircle = Circle(center: self.center, radius: self.side / 2)
        
        return newCircle
    }
    
    func generateRandomInsidePoint() -> Point {
        
        let xMin = self.center.x - self.side / 2
        let xMax = self.center.x + self.side / 2
        let yMin = self.center.y - self.side / 2
        let yMax = self.center.y + self.side / 2
        
        let xRandom = Random.within(xMin...xMax)
        let yRandom = Random.within(yMin...yMax)
        
        return Point(x: xRandom, y: yRandom)
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////


struct trial {
    
    var insideCircleTally: Int = 0
    var totalPoints: Int = 0
    
    var est_PI: Double {
        
        get{
            return (4.0 * Double(self.insideCircleTally)) / Double(self.totalPoints)
        }
    }
    
    var percentError: Double {
        
        get {
            return (abs( self.est_PI - M_PI ) / M_PI) * 100
        }
    }
}

struct Experiment {
    
    var newSquare: Square
    var newInscribedCircle: Circle
    
    
    var nTrials: Int
    var trials: [trial] = []
    
    var nPointsInEachTrial: Int
    
    var sumOf_PIestimations: Double {
        
        get {
            
            var sumToReturn = 0.0
            
            for index in trials {
                
                sumToReturn = sumToReturn + index.est_PI
            }
            return sumToReturn
        }
    }
    
    var average_PIestimation: Double {
        
        get {
            
            return sumOf_PIestimations / Double(trials.count)
        }
    }
    
    var average_PercentError: Double {
        
        get {
            
            var sumOf_PercentErrors = 0.0
            
            for index in trials {
                
                sumOf_PercentErrors = sumOf_PercentErrors + index.percentError
            }
            
            return sumOf_PercentErrors / Double(trials.count)
        }
    }
    
    
    
    
    init(squareCenter: Point, squareSideLength: Double, nTrials: Int, pointsPerTrial: Int) {
        
        self.newSquare = Square(center: squareCenter, side: squareSideLength)
        self.newInscribedCircle = self.newSquare.createInscribedCircle()
        self.nTrials = nTrials
        self.nPointsInEachTrial = pointsPerTrial
    }
    
// This is where the Monte Carlo algorithm is...
    
    mutating func rollTheDiceFor_PI() {
        
        for _ in 0..<(self.nTrials) {
            
            var newTrial = trial()
            
            for _ in 0..<(self.nPointsInEachTrial) {
                
                let newPoint = self.newSquare.generateRandomInsidePoint()
                
                if (self.newInscribedCircle.isInsideMe(newPoint)) {
                    
                    newTrial.insideCircleTally++
                }
                
                newTrial.totalPoints++
            }
            
            self.trials.append(newTrial)
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////

//: Example

var testExperiment = Experiment(squareCenter: Point(x: 0, y: 0), squareSideLength: 2.0, nTrials: 10, pointsPerTrial: 100)

testExperiment.rollTheDiceFor_PI()

testExperiment.trials
testExperiment.average_PIestimation
testExperiment.average_PercentError


