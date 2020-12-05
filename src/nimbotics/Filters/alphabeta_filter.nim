import random
import os

let
    dt = 0.5
    a = 0.5
    b = 0.005
var
    xk_1,xk,vk_1,vk,rk,xm:float

for _ in 1..100:
    xm = (rand(32767) mod 100).float
    xk = xk_1 + (vk_1 * dt)
    vk = vk_1
    rk = xm - xk
    xk += a*rk
    vk += (b * rk) / dt
    xk_1 = xk
    vk_1 = vk
    echo xm," ",xk_1
    100.sleep