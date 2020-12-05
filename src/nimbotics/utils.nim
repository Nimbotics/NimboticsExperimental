import macros


proc linspace*(start, stop: float, num: int, endpoint = true): seq[float] =
  ## linspace similar to numpy's linspace
  ## returns a seq containing a linear spacing starting from `start` to `stop`
  ## eitther including (endpoint == true) or excluding (endpoint == false) `stop`
  ## with a number of `num` elements
  result = @[]
  var 
    step = start
    diff: float
  if endpoint == true:
    diff = (stop - start) / float(num - 1)
  else:
    diff = (stop - start) / float(num)
  if diff < 0:
    # in case start is bigger than stop, return an empty sequence
    return @[]
  else:
    for i in 0..<num:
      result.add(step)
      # for every element calculate new value for next iteration
      step += diff

proc recursiveSearch(body: Nimnode, indices:seq[int], value:NimNode):seq[seq[int]] = 
  var indices = indices
  for index, node in body.pairs:
    if node == value:
      var indices = indices
      indices.add index
      result.add indices
    else:
      var indices = indices
      indices.add index
      result.add recursiveSearch(node, indices, value)

proc get(node:Nimnode,indices:varargs[int]):Nimnode =
  if indices.len > 1:
    node[indices[0]].get(indices[1..^1])
  else:
    node[indices[0]]

template `[]`(node:Nimnode,indices:varargs[int]):untyped =
  node.get(indices)

proc change(node:Nimnode,indices:varargs[int],value:Nimnode) =
  if indices.len > 1:
    node[indices[0]].change(indices[1..^1],value)
  else:
    node[indices[0]] = value

template `[]=`(node:Nimnode, indices:varargs[int], value:Nimnode):untyped =
  node.change(indices,value)
    
macro unrollLoop*(i:HSlice[int,int],body:untyped):untyped =
  result = nnkstmtlist.newtree()
 
  var start:Biggestint
  var last:Biggestint

  if i.kind == nnkInfix:
    
    start = i[1].intval
    last = i[2].intval
  elif i.kind == nnkstmtlistExpr:
    var iter = i.findchild(it.kind == nnkInfix)
    start = iter[1].intval
    last = iter[2].intval
  let 
    indices = recursiveSearch(body, @[], newIdentNode "i")

  for val in start..last:
    for index in indices:
      body[index] = newintlitnode(val)
    var blck = nnkBlockStmt.newTree()
    blck.add newemptynode()
    blck.add copy(body)
  
    result.add blck