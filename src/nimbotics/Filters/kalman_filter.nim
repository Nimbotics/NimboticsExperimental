import neo
import sequtils
import ../utils
import math

proc `+`[V:SomeNumber](a: Matrix[V],b:V): Matrix[V] = 
    a.map(proc(x:V):V = x+b)

proc kalman[V](x, P:Matrix[V], measurement:seq[V], R:V, motion, Q, F, H:Matrix[V]): (Matrix[V],Matrix[V]) =
    var
        K = P * H.T * ((H * P * H.T) + R).inv
        x = x + K*(matrix(@[measurement]).T - (H*x))
        P = (eye(F.M,V) - K*H)*P
    x = F*x + motion
    P = F*P*F.T + Q
    
        
    return (x,P)
when isMainModule:
    var
        x = zeros(4,1,float)
        p = eye(4,float)*1000
        result:seq[seq[float]]
    
    let
        N = 20
        true_x = matrix(@[linspace(0,10,N)])
        true_y = true_x.map(proc(x:float): float=x^2)
        observed_x = true_x + 0.05*(randomMatrix(1,N) |*| true_x)
        observed_y = true_y + 0.05*(randomMatrix(1,N) |*| true_y)
        R = 0.01^2
        motion = zeros(4,1,float)
        q = eye(4,float)
        F = matrix(@[@[1.0,0.0,1.0,0.0],
                    @[0.0,1.0,0.0,1.0],
                    @[0.0,0.0,1.0,0.0],
                    @[0.0,0.0,0.0,1.0]])
        H = matrix(@[@[1.0,0.0,0.0,0.0],
                    @[0.0,1.0,0.0,0.0]])
    #echo F.inv
    for meas in zip(observed_x.toSeq,observed_y.toseq):
        (x,p) = kalman(x,p,@[meas[0],meas[1]],R,motion,q,F,H)
        result.add(x[0..1,0..0].toSeq)
        discard
    echo result
    

