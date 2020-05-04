import neo
import sequtils
import seqmath/util
import math

proc `+`(a: Matrix,b:float64): Matrix = 
    a.map(proc(x:float64):float64=x+b)

proc kalman(x, P:Matrix, measurement:seq, R:float, motion, Q, F, H:Matrix): (Matrix,Matrix) =
    var
        K = P * H.T * ((H * P * H.T) + R).inv
        x = x + K*(matrix(@[measurement]).T - (H*x))
        P = (eye(F.M) - K*H)*P
    x = F*x + motion
    P = F*P*F.T + Q
    
        
    return (x,P)
if isMainModule:
    var
        x = zeros(4,1)
        p = eye(4)*1000
        result:seq[seq[float64]]
    
    let
        N = 20
        true_x = matrix(@[linspace(0,10,N)])
        true_y = true_x.map(proc(x:float): float=x^2)
        observed_x = true_x + 0.05*(randomMatrix(1,N) |*| true_x)
        observed_y = true_y + 0.05*(randomMatrix(1,N) |*| true_y)
        R = 0.01^2
        motion = zeros(4,1)
        q = eye(4)
        F = matrix(@[@[1.0,0.0,1.0,0.0],
                    @[0.0,1.0,0.0,1.0],
                    @[0.0,0.0,1.0,0.0],
                    @[0.0,0.0,0.0,1.0]])
        H = matrix(@[@[1.0,0.0,0.0,0.0],
                    @[0.0,1.0,0.0,0.0]])
    for meas in zip(observed_x.toSeq,observed_y.toseq):
        (x,p) = kalman(x,p,@[meas[0],meas[1]],R,motion,q,F,H)
        result.add(x[0..1,0..0].toSeq)
    echo result

