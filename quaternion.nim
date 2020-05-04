import strformat
import math

type Quaternion* = object
  w*,x*,y*,z*:float
proc quaternion(w,i,j,k:float): Quaternion =
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
proc `+` *(q, p: Quaternion): Quaternion =
  result.w = q.w + p.w
  result.x = q.x + p.x
  result.y = q.y + p.y
  result.z = q.z + p.z
proc `-` *(q, p: Quaternion): Quaternion =
  result.w = q.w - p.w
  result.x = q.x - p.x
  result.y = q.y - p.y
  result.z = q.z - p.z
  
proc `$` *(q:Quaternion): string =
  result = fmt"{q.w} + {q.x}i + {q.y}j + {q.z}k"
  
proc `*` *(q, p: Quaternion): Quaternion = 
  result.w = q.w*p.w - q.x*p.x - q.y*p.y - q.z*p.z
  result.x = q.w*p.x + p.w*q.x + q.y*p.z - q.z*p.y
  result.y = q.w*p.y - q.x*p.z + q.y*p.w + q.z*p.x
  result.z = q.w*p.z + q.x*p.y - q.y*p.x + q.z*p.w

proc `*` *(c:float, q: Quaternion): Quaternion = 
  result = Quaternion(w: c*q.w, x: c*q.x, y: c*q.y, z: c*q.z)
proc dot *(q, p: Quaternion): float =
  result = q.w * p.w + q.x * p.x + q.y * p.y + q.z * p.z
proc `/` *(q:Quaternion, c:float): Quaternion = 
  result.w = q.w/c
  result.x = q.x/c
  result.y = q.y/c
  result.z = q.z/c
proc conjugate *(q: Quaternion): Quaternion = 
  result = quaternion(q.w,-q.x,-q.y,-q.z)
proc inv *(q:Quaternion):Quaternion = q.conjugate
proc length *(q: Quaternion): float =
  result = sqrt(q.w^2 + q.x^2 + q.y^2 + q.z^2)
proc normalize *(q:Quaternion): Quaternion =
  result = q/length(q)
proc i *(f:float): Quaternion = 
  result = Quaternion(x:f)
proc j *(f:float): Quaternion = 
  result = Quaternion(y:f)
proc k *(f:float): Quaternion = 
  result =  Quaternion(z:f)


if isMainModule:
  let q =  quaternion(1,2,3,4)
  let p = Quaternion(w:5,x:6,y:7,z:8)
  let l =  q * p + 3.i + 2.j
  assert l == quaternion(-60,15,32,24)
  let r = quaternion([7.0,8,9])
  echo r*r.inv