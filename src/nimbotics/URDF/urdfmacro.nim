import macros

type jcat = enum
  rotary
template pass = discard
macro Robot(name:string,metabody: untyped) =
  var body1, body2: NimNode
  for body in metabody:
    #echo body.repr
    echo "-------------------"
    if body.kind == nnkCommand or body.kind == nnkCall:
    
      if body[0].eqIdent "Joint":
        for sub in body[1..^1]:
          echo sub.repr
      
      
      elif body[0].eqIdent "Link":
        body2 = body[1]
    

  # [...] do stuff with body1 and body2
  #echo body1.treeRepr
  #echo body2.treeRepr

Robot "steve":
  Joint "wrist", rotary:
    origin(xyz="0 -0.22 0.25", rpy="0 0 0")
    parent "arm"
    child "hand"
  Link "arm":
    visual:
      geometry:
        box "0.6 0.1 0.2"
      origin(xyz="0 -0.22 0.25", rpy="0 0 0")
      material "white"
  Link "hand":
   visual:
     geometry:
       box "0.6 0.1 0.2"
     origin(xyz="0 -0.22 0.25", rpy="0 0 0")
     material "white"