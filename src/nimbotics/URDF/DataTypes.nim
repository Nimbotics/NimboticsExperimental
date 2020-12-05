import sequtils
import strutils
import tables


proc seqToTuple*(tup: var tuple, s:seq) =
  tup[0] = s[0]
  tup[1] = s[1]
  tup[2] = s[2]
  
proc parseseqfloat*(inp:string): seq[float] =
    inp.split.map(parsefloat)

#proc tableToSeq[key,pair](tab:Table[key,pair]):

type shapekind* = enum
  cylinder, sphere, box, mesh


type Shape* = object
  case kind*: shapekind
  of cylinder:
    cradius*:float
    length*:float
  of sphere:
    sradius*:float
  of box:
    xlength*:float
    ylength*:float
    zlength*:float
  of mesh:
    filename*:string
    scale*:float

type category* = enum
  revolute = "revolute"
  continuous = "continuous"
  prismatic = "prismatic"
  fixed = "fixed"
  floating = "floating"
  planar = "planar"

template required* {.pragma.}
template optional* {.pragma.}
template child* {.pragma.}
template attribute* {.pragma.}


type 
    position* = tuple[x:float,y:float,z:float]
    orientation* = tuple[r:float,p:float,y:float]
    inertia* = tuple[ixx:float,ixy:float,ixz:float,iyy:float,iyz:float,izz:float]
    rgba* = tuple[red,green,blue,alpha:0.0..1.0]
    material* = object
    #    refmat*:bool
        name*{.required, attribute.}: string
        color*{.optional, child.}: rgba
        texture*{.optional, child.}: string
    origin* = object
        xyz*: position
        rpy*: orientation
    visual* = object
        name*:string
        geometry*: Shape
        origin*: origin
        material*:material
    collision* = object
        name*:string
        geometry*: Shape
        origin*: origin
    calibration* = object
        rising*:float
        falling*:float
    inertial* = object
        origin*:origin
        mass*: float
        inertia*: inertia
    dynamics* = object
        damping*:float
        friction*:float
    limit* = object
        lower*:float
        upper*:float
        effort*:float
        velocity*:float
    safety_controller* = object
        soft_lower_limit*:float
        soft_upper_limit*:float
        k_position*:float
        k_velocity*:float
    link* = object
        name*: string
        visual*:visual
        collision*:collision
        inertial*:inertial
    joint* = object
        name*{.required, attribute.}:string
        category*{.required, attribute.}:category
        origin*{.optional, child.}:origin
        parent*{.required, child.}:link
        child*{.required, child.}:link
        axis*{.optional, child.}:position
        calibration*{.optional, child.}:calibration
        dynamics*{.optional, child.}:dynamics
        limit*{.optional, child.}:limit
        safety_controller*{.optional, child.}:safety_controller
    robot* = object
        name*:string
        joints*:OrderedTable[string, joint]
        links*:OrderedTable[string, link]
        materials*:OrderedTable[string, material]


proc identity* (o:origin):bool =
    o.xyz == (0.0,0.0,0.0) and o.rpy == (0.0,0.0,0.0)