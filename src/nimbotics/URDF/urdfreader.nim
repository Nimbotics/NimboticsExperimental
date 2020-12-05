import 
    xmlparser,
    xmltree,
    tables,
    strutils,
    parseutils,
    sequtils,
    macros,
    DataTypes,
    parsermacro


proc attrnode(name,attr,value:string): XmlNode =
    result = newElement(name)
    result.attrs = {attr:value}.toXmlAttributes

proc toXML(s:Shape): Xmlnode =
  let a = newelement($s.kind)
  var b: XmlAttributes
  case s.kind
  of cylinder: b = {"length": $s.length, "radius": $s.cradius}.toXmlAttributes
  of sphere: b =  {"radius": $s.sradius}.toXmlAttributes
  of box: b = {"shape": $s.xlength & " " & $s.ylength & " " & $s.zlength}.toXmlAttributes
  of mesh: b =  {"filename": $s.filename, "scale": $s.scale}.toXmlAttributes
  a.attrs = b
  result = newxmltree("geometry",[a])

proc toXML(color:rgba):XmlNode =
    result = newElement("color")
    result.attrs = {"rgba": $color.red & " " & $color.green & " " & $color.blue & " " & $color.alpha}.toXmlAttributes

proc toXML(mat:material):XmlNode =
    result = newXmlTree("material",[mat.color.toXML],{"name":mat.name}.toXmlAttributes)

proc toXML(orig:origin):XmlNode =
    result = newElement("origin")
    result.attrs = {"xyz": $orig.xyz.x & " " & $orig.xyz.y & " " & $orig.xyz.z,
     "rpy": $orig.rpy.r & " " & $orig.rpy.p & " " & $orig.rpy.y}.toXmlAttributes

proc toXML(vis:visual):XmlNode =
    var mat:XmlNode
    var branches = @[vis.geometry.toXML]

    #if vis.material.refmat:
    mat = attrnode("material","name",vis.material.name)
    #else:
    #    mat = vis.material.toXML
    #branches.add(mat)
    if not vis.origin.identity:
        branches.add(vis.origin.toXML)
    result = newXmlTree("visual", branches)
    if not vis.name.isEmptyOrWhitespace:
        result.attrs= {"name":vis.name}.toXmlAttributes

proc toXML(coll:collision):XmlNode = discard
    

proc toXML(l:link):XmlNode =
    result = newXmlTree("link",[l.visual.toXML])
    result.attrs= {"name":l.name}.toXmlAttributes

proc toXML(j:joint):XmlNode =
    result = newXmlTree("joint",[attrnode("parent","link",j.parent.name),
               attrnode("child","link",j.child.name), j.origin.toXML])
    result.attrs= {"name":j.name,"type": $j.category}.toXmlAttributes

proc tabletoseq[A,B](tab:OrderedTable[A,B]): seq[B] = 
    for val in tab.values:
        result.add(val)

proc toXML(rob:robot):XmlNode = 
    
    newXmlTree("robot",rob.materials.tabletoseq.map(toXML) & rob.links.tabletoseq.map(toXML) & rob.joints.tabletoseq.map(toXML),{"name":rob.name}.toXmlAttributes)





proc originInit(xyz:position=(0.0,0.0,0.0),rpy:orientation=(0.0,0.0,0.0)):origin =
    result.xyz = xyz
    result.rpy = rpy

proc parseColor(inp:string): rgba =
    let colseq = inp.parseseqfloat
    result.red = colseq[0]
    result.green = colseq[1]
    result.blue = colseq[2]
    result.alpha = colseq[3]

template getorigin(part,node:untyped):untyped=
        if not node.child("origin").isNil:
            var origobj : origin
            let orig = node.child("origin")
            if not orig.attr("xyz").isEmptyOrWhitespace:
                let xyz = orig.attr("xyz").parseseqfloat
                origobj.xyz.seqToTuple(xyz)
            else:
                origobj.xyz = (0.0,0.0,0.0)
            if not orig.attr("rpy").isEmptyOrWhitespace:
                let rpy = orig.attr("rpy").parseseqfloat
                origobj.rpy.seqToTuple(rpy)
            else:
                origobj.rpy = (0.0,0.0,0.0)
            part.origin = origobj
        else:
            part.origin = originInit()

proc getshape(geo:XmlNode):Shape =
    for kid in geo:
        case kid.tag:
            of "cylinder":
                let leng = geo.child("cylinder").attr("length").parseFloat
                let radi = geo.child("cylinder").attr("radius").parseFloat
                result = Shape(kind:cylinder,length:leng,cradius:radi)
            of "box":
                let size = geo.child("box").attr("size").parseseqfloat
                result = Shape(kind:box,xlength:size[0], ylength:size[1], zlength:size[2])
            of "sphere":
                let radi = geo.child("sphere").attr("radius").parseFloat
                result = Shape(kind:sphere, sradius:radi)
            of "mesh":
                let filename = geo.child("mesh").attr("filename")
                result = Shape(kind:mesh,filename:filename)

macro fillvalues(node:XmlNode,obj:typed,attributes:varargs[untyped]):untyped = 
  result = newstmtlist()
  for atr in attributes:
    let atrStr = atr.strVal
    result.add quote do:
      if not `node`.attr(`atrStr`).isEmptyOrWhitespace:
        `obj`.`atr` = `node`.attr(`atrStr`).parseFloat
  
proc ParseURDF(xml:XmlNode):robot =
    let file = xml
    result.name = file.attr("name")
    var materials : OrderedTable[string,material]
    for val in file.findAll("material"):
        
        if not val.child("color").isNil:
            let name = val.attr("name")
            let col = val.child("color").attr("rgba").parseColor
            materials[name] = material(name:name,color:col)
    var links : OrderedTable[string,link]
    for val in file.findAll("link"):
        var lin:link
        let name = val.attr("name")
        lin.name = name
        if not val.child("visual").isNil:
            var visu:visual
            let vis = val.child("visual")
            visu.geometry = vis.child("geometry").getshape
            
            getorigin(visu,vis)
     
            if not vis.child("material").isNil:
                let mat = vis.child("material")
                if mat.attr("name") in materials:
                    visu.material = materials[mat.attr("name")]
                    #visu.material.refmat = true
            lin.visual = visu
        if not val.child("inertial").isNil:
            var inert:inertial
            let inertnode = val.child("inertial")
            getorigin(inert,inertnode)
            inert.mass = inertnode.child("mass").attr("value").parseFloat
            let inertinert = inertnode.child("inertia")
            var inertiavalues :seq[float]
            for ax in ["ixx","ixy","ixz","iyy","iyz","izz"]:
                inertiavalues.add inertinert.attr(ax).parseFloat
            inert.inertia.seqToTuple(inertiavalues)
            lin.inertial = inert
        if not val.child("collision").isNil:
            var coll:collision
            let collnode = val.child("collision")
            getorigin(coll,collnode)
            coll.geometry = collnode.child("geometry").getshape
            if not collnode.attr("name").isEmptyOrWhitespace:
                coll.name = collnode.attr("name")

        links[name] = lin
    var joints : OrderedTable[string,joint]
    for val in file.findAll("joint"):
        var j:joint
        var name = val.attr("name")
        j.name = name
        let cat = val.attr("type")
        for valcat in category:
            if cat == $valcat:
                j.category = valcat
        getorigin(j,val)
        
        if not val.child("calibration").isNil:
            var calib:calibration
            fillvalues(val.child("calibration"),calib,rising,falling)
            j.calibration = calib
        
        if not val.child("dynamics").isNil:
            var dyn :dynamics
            fillvalues(val.child("dynamics"),dyn,damping,friction)
            j.dynamics = dyn
        
        if not val.child("limit").isNil:
            var lim :limit
            fillvalues(val.child("limit"),lim,lower,upper)
            lim.effort = val.child("limit").attr("effort").parseFloat
            lim.velocity = val.child("velocity").attr("velocity").parseFloat
            j.limit = lim

        if not val.child("safety_controller").isNil:
            var safe_con:safety_controller
            fillvalues(val.child("safety_controller"),safe_con,soft_lower_limit, soft_upper_limit, k_position)
            j.safety_controller = safecon
        j.child = links[val.child("child").attr("link")]
        j.parent = links[val.child("parent").attr("link")]

        joints[name] = j
    result.links = links
    result.joints = joints
    result.materials = materials


when isMainModule:
    let testfile = "visual.urdf".loadXml
    #for val in testfile.findAll("material"):
    #    Parser material
    var a = testfile.ParseURDF
    echo a.toXML
