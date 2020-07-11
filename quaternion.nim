{.experimental: "callOperator".}
import strformat
import math

type Quaternion* = object
  w*,x*,y*,z*:float

using
  q,p:Quaternion
  c,f:float

proc quaternion *(w,i,j,k:float): Quaternion =
  result.w = w
  result.x = i
  result.y = j
  result.z = k
proc quaternion *(m:array[3,float]): Quaternion =
  result.w = 0
  result.x = m[0]
  result.y = m[1]
  result.z = m[2]
proc quaternion *(m:array[4,float]): Quaternion =
  result.w = m[0]
  result.x = m[1]
  result.y = m[2]
  result.z = m[3]
proc `+` *(q, p): Quaternion =
  result.w = q.w + p.w
  result.x = q.x + p.x
  result.y = q.y + p.y
  result.z = q.z + p.z
proc `-` *(q, p): Quaternion =
  result.w = q.w - p.w
  result.x = q.x - p.x
  result.y = q.y - p.y
  result.z = q.z - p.z
  
proc `$` *(q): string =
  result = fmt"{q.w} + {q.x}i + {q.y}j + {q.z}k"
  
proc `*` *(q, p): Quaternion = 
  result.w = q.w*p.w - q.x*p.x - q.y*p.y - q.z*p.z
  result.x = q.w*p.x + p.w*q.x + q.y*p.z - q.z*p.y
  result.y = q.w*p.y - q.x*p.z + q.y*p.w + q.z*p.x
  result.z = q.w*p.z + q.x*p.y - q.y*p.x + q.z*p.w

proc `*` *(c:float, q): Quaternion = 
  result = Quaternion(w: c*q.w, x: c*q.x, y: c*q.y, z: c*q.z)
proc dot *(q, p): float =
  result = q.w * p.w + q.x * p.x + q.y * p.y + q.z * p.z
proc `/` *(q, c): Quaternion = 
  result.w = q.w/c
  result.x = q.x/c
  result.y = q.y/c
  result.z = q.z/c
proc conjugate *(q): Quaternion = 
  result = quaternion(q.w,-q.x,-q.y,-q.z)
proc inv *(q):Quaternion = q.conjugate
proc length *(q): float =
  result = sqrt(q.w^2 + q.x^2 + q.y^2 + q.z^2)
proc normalize *(q): Quaternion =
  result = q/length(q)
proc i *(f): Quaternion = 
  result = Quaternion(x:f)
proc j *(f): Quaternion = 
  result = Quaternion(y:f)
proc k *(f): Quaternion = 
  result =  Quaternion(z:f)

type
  Slerp = object
    start,final:Quaternion
    dotprod:float
    theta_0:float
    sin_theta_0:float

proc slerp (q,p): Slerp =
  var v1 = q.normalize
  var v2 = p.normalize
  var dotprod = dot(v1,v2)
  if dotprod < 0d:
    v1 = -1*v1
    dotprod = -dotprod
  var theta_0 = arccos(dotprod)
  var sin_theta_0 = sin(theta_0)
 
  result.start = v1
  result.final = v2
  result.dotprod = dotprod
  result.theta_0 = theta_0
  result.sin_theta_0 = sin_theta_0
proc call (s:Slerp,t:0d..1d): Quaternion =
  let theta = s.theta_0 * t
  let sin_theta = sin(theta)
  let s0 = cos(theta) - s.dotprod * sin_theta / s.sin_theta_0
  let s1 = sin_theta / s.sin_theta_0
  
  result = (s0 * s.start) + (s1 * s.final)

proc `..` (q,p): Slerp = 
  result = slerp(q,p)

when isMainModule:
  let q =  quaternion(1,2,3,4)
  let p = Quaternion(w:5,x:6,y:7,z:8)
  let l =  q * p + 3.i + 2.j
  let s = q..p
  assert l == quaternion(-60,15,32,24)
  let r = quaternion([7.0,8,9])
  echo r*r.inv
  echo q.normalize
  echo p.normalize
  echo s.call(0.0)
  echo s.call(1.0)