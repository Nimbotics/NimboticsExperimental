import math
#include quaternion

type coords* = tuple
    x,y:float

proc `+` *(a,b:coords): coords =
    result = (a[0] + b[0], a[1]+b[1])

proc `+=` *(a: var coords,b:coords) =
    a = a + b

proc `-` *(a,b:coords): coords =
  result = (a[0] - b[0], a[1] - b[1])

proc `-=` *(a: var coords,b:coords) =
    a = a - b
proc magnitude *(a:coords):float = (a[0]^2 + a[1]^2).sqrt

proc magnitude *(a,b:coords): float = (b-a).magnitude

proc angle *(a,b:coords):float =
    let vec = b-a
    result = arctan2(vec[1],vec[0])

type joint* = ref object of RootObj
    connection*:joint
    pos*:coords
proc `x` *(j:joint): float = j.pos[0]
proc `y` *(j:joint): float = j.pos[1]

proc `$` *(j:joint): string =
    result.add("coordinates: " & $j.pos & "\nConnected: " & $ (not j.connection.isNil))
  
proc connect *(j1,j2:joint):joint {.discardable.} =
  j1.connection = j2
  result = j2

type 
    rotary_joint* = ref object of joint

    linear_joint* = ref object of joint

    end_effector* = ref object of joint

    joint_type* = enum
        rotary, linear, effector

method angle *(j1,j2:joint): float = j1.pos.angle(j2.pos)

method magnitude *(j1,j2:joint): float = j1.pos.magnitude(j2.pos)
    
method move(j1:joint,amount:coords) = 
    j1.pos += amount

method chain_move(j1:joint, amount:coords) = 
    j1.connection.pos += amount
    if j1.connection.connection.isNil:
        return
    j1.connection.chain_move(amount)

method chain_rotate(j1,j2:joint,amount:float) =
    
    let x = cos(amount)*(j2.x-j1.x) - sin(amount)*(j2.y-j1.y) + j1.x
    
    let y = sin(amount)*(j2.x-j1.x) + cos(amount)*(j2.y-j1.y) + j1.y
    j2.pos = (x,y)
    if j2.connection.isNil:
        return
    j1.chain_rotate(j2.connection, amount)
  
method rotate(j1: joint, amount: -Tau..Tau) {.base.} = discard

method extend(j1: joint, amount: float) {.base.} = discard

method rotate *(j1: rotary_joint, amount: -Tau..Tau) =
    if j1.connection.isNil:
        return
    j1.chain_rotate(j1.connection, amount)
    
method extend *(j1: linear_joint, amount:float) = 
    if j1.connection.isNil:
        return
    let angle = j1.angle(j1.connection)
  
    let dx = amount*cos(angle)
    let dy = amount*sin(angle)

    j1.chain_move((dx,dy))


proc initJoint *(category:joint_type, position:coords): joint =
    case category 
    of rotary:
        return rotary_joint(pos:position)
    of linear:
        return linear_joint(pos:position)
    of effector:
        return end_effector(pos:position)

when isMainModule:
    let base = rotary.initJoint((64.0,64.0))
    let secondary = linear.initJoint((64.0,84.0))
    let tertiary = effector.initJoint((84.0,84.0))
    base.connect(secondary).connect(tertiary)
    for dt in 1..1000:
        base.rotate(1)
        echo secondary
        
    

    
