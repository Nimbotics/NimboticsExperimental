import delaunay
import nigui
from sequtils import newSeqWith
from random import rand, randomize
from times import now

# Points can be any object with an `x` and `y` field
const
  img_width  = 800
  img_height = 800
  nSites = 50
 
proc dot(x, y: int): int = x * x + y * y

randomize(cast[int64](now()))

let sx = newSeqWith(nSites, rand(img_width))
let sy = newSeqWith(nSites, rand(img_height))
let sc = newSeqWith(nSites, rgb(rand(255).byte, rand(255).byte, rand(255).byte))

app.init()
var window = newWindow()
window.width = img_width
window.height = img_height

var control1 = newControl()
window.add(control1)
# Creates a drawable control

control1.widthMode = WidthMode_Fill
control1.heightMode = HeightMode_Fill
control1.onDraw = proc (event: DrawEvent)=
    let canvas = event.control.canvas
    for x in 0 ..< img_width:
        for y in 0 ..< img_height:
            var dMin = dot(img_width, img_height)
            var sMin: int
            for s in 0 ..< nSites:
                if (let d = dot(sx[s] - x, sy[s] - y); d) < dMin:
                    (sMin, dMin) = (s, d)
                    canvas.setPixel(x,y,sc[sMin])
    for s in 0 ..< nsites:
        canvas.drawRectArea(sx[s] - 2, sy[s] - 2,4,4)
window.show()
app.run()




