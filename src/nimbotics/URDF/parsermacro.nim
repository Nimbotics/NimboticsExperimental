import macros
import DataTypes
import macroutils
  
proc Parser(body:Nimnode):Nimnode =
  body.expectkind nnkTypeDef
  result = newStmtList()
  #echo body[0].repr
  let symb = genSym()
  var variable = VarSection(IdentDefs(symb,Empty(),Call(Ident(body[0].repr))))
  result.add variable
  #echo variable.treerepr
  for nod in body[2]:
    if nod.kind == nnkRecList:
      for attr in nod:
        #echo attr.repr
        let typ = attr[1]
        let prag = attr[0][1]
        let opt =  prag[0]
        let place = prag[1]
        let name = attr[0][0]
        #echo typ.getImpl.kind
        if typ.getimpl == nil:
          if typ.repr == "string":
            echo name.repr
        elif typ.repr == "rgba":
          discard
        else:
          discard Parser typ.getimpl
        #echo attr.kind
        #echo "-----------------"
    elif nod.kind == nnkIdentDefs:
      echo body[0].repr

macro Parser*(inp:type):untyped =
  let body = inp.getimpl
  discard Parser body
  
when isMainModule:
  type sub = object
    a {.required, attribute.} : int

  type test = object
    a {.required, attribute.} : int
    b {.optional, child.} : string
    c {.optional, child.} : sub
  Parser test