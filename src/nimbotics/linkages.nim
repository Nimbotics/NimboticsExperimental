import neo
import neo/statics
import modern_robotics
import math
import utils

type 
    JointType* = enum
        rotary,linear,effector
    Joint*[V] = ref object
        name:string
        initialPosition: TriVector[V]
        currentPosition*: TriVector[V]
        orientation*: AxisAng[V]
        kind:JointType

    Robot*[N:static[int],V] = ref object
        name:string
        joints: array[N,Joint[V]]
        ScrewAxes: StaticMatrix[6,N,V]
        JointFrames:seq[HomogenousMatrix[V]]


proc `$`*[V](j:Joint[V]): string =
    result.add($j.kind & "joint:\n")
    result.add("\t home position: " & j.initialposition.pretty & "\n")
    result.add("\t current position: " & j.currentposition.pretty & "\n")
    result.add("\t orientation: " & $j.orientation & "\n")

proc joint*[V](kind:JointType, position:TriVector[V], orientation:AxisAng[V]): Joint[V] = 
    ##[
        for a rotary joint the orientation is the unit vector along which the
        joint rotates and is relative to the fixed base frame which for now
        will be at the (0,0,0)

        for a linear joint the orientation will be the unit vector along wich 
        the joint moves along

    ]##
    result = new Joint[V]
    result.kind = kind
    result.currentposition = position
    result.initialPosition = position
    result.orientation = orientation


proc joint*[V](kind:JointType, position:TriVector[V], orientation:TriVector[V]): Joint[V] =
    ##[
        for a rotary joint the orientation is the unit vector along which the
        joint rotates and is relative to the fixed base frame which for now
        will be at the (0,0,0)

        for a linear joint the orientation will be the unit vector along wich 
        the joint moves along

    ]##
    joint(kind, position, orientation.AxisAng3)


proc joint*[V](kind:JointType, position:array[3,V], orientation:array[3,V]): Joint[V] =
    ##[
        for a rotary joint the orientation is the unit vector along which the
        joint rotates and is relative to the fixed base frame which for now
        will be at the (0,0,0)

        for a linear joint the orientation will be the unit vector along wich 
        the joint moves along

    ]##
    joint(kind, vector position, vector orientation)
  

proc robot*[N:static[int],V](joints:array[N,Joint[V]]):Robot[N,V]  =
    result = new Robot[N,V]
    result.joints = joints
    var screwaxes = zeros[V](6,N)
    for i in 0..<N:
        result.JointFrames.add:
            AxisAngToRotation(joints[i].orientation).RpToTrans(joints[i].initialPosition)
        var omega,v:StaticVector[3,V]
        case joints[i].kind:
            of linear:
                omega = vector([0.0,0,0])
                v = joints[i].orientation[0] 
            of rotary:
                let 
                    q = joints[i].initialPosition
                omega = joints[i].orientation[0]
                v = (-1.0 * omega) >< q
            of effector:
                omega = vector([0.0,0,0])
                v = vector([0.0,0,0])
        screwaxes[ALL, i..i] = hstack(omega.asDynamic, v.asDynamic).asMatrix(6,1)
        
    result.Screwaxes = screwaxes.asStatic(6,N)

proc Forward*[N:static[int],V](rob:Robot[N,V],thetalist:StaticVector[N,V]): QuadMatrix[V] = 
    FKinSpace(rob.JointFrames[^1], rob.ScrewAxes, thetalist)

proc ChainForward*[N:static[int],V](rob:Robot[N,V],thetalist:StaticVector[N,V]): seq[QuadMatrix[V]]=
    unrollLoop(0..<N):
        result.add FKinSpace(rob.JointFrames[i], rob.ScrewAxes[All,0..i], thetalist[0..i])

when isMainModule:

    let origorient = vector([0.0,0,1])
    let secondorient = vector([0.0, 0, 1])
    let endorient = vector([0.0,0,1])

    let origpos = vector([0.0,0,0])
    let secondpos = vector([3.0,0,0])
    let endpos = vector([6.0,0,0])

    let a = rotary.joint(origpos, origorient)
    let b = rotary.joint([3.0,0,0], [0.0,0,1])
    let c = rotary.joint(endpos, endorient)
    let rob = robot([a,b,c])
    
    let motion = rob.ChainForward(vector [Pi/2,Pi/2,0])
    for i,step in motion:
        echo "Joint ",$i 
        echo step.TransToRp.pretty
    #echo rob.JointFrames[^1]
    echo rob.Forward(vector([Pi/2,Pi/2,0])).TransToRp.pretty
   
