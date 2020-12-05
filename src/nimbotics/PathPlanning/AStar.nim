import tables
import deques
import strutils

type Graph[T] = object
    edges:Table[T, seq[T]]

proc newNode[T](graph:var Graph[T], node:T) = 
  graph.edges[node] = @[]

proc addEdge[T](graph:var Graph[T], node1,node2:T) = 
  graph.edges[node1].add(node2)

proc empty(deque:Deque): bool = not (len(deque) > 0)

proc breadth_first_search_1[T](graph:Graph[T],start:T) = 
    var frontiers : Deque[T]
    frontiers.addLast(start)
    var visited: Table[T, bool]
    visited[start] = true
    while not frontiers.empty:
        var current = frontiers.popFirst
        echo "Visiting " , current
        for next in graph.edges[current]:
            if not (next in visited):
                frontiers.addLast(next)
                visited[next] = true

type Grid = object
  graph:Graph[(int,int)]
  width,height:int
  walls:seq[(int, int)]

proc `$` (g:Grid): string = 
  for row in 1..g.height:
    result.add(".".repeat(g.width) & "\n")
  for pos in g.walls:
    var place = (pos[0]-1) + (pos[1]-1)*11
    result[place] = '#'

proc gridgraph (width:int, height:int, walls:seq[(int,int)]): Grid =
    result.walls = walls
    result.width = width
    result.height = height
    for x in 0..width:
      for y in 0..height:
        let position = (x,y)
        if not (position in walls):
          result.graph.newNode(position)
        else:
          continue
        var new_pos = (x-1,y)
        
        if new_pos[0] > 0:
          if not (position in walls):
            result.graph.addEdge(position,new_pos)
        new_pos = (x+1, y)
        if new_pos[0] < width:
          if not (position in walls):
            result.graph.addEdge(position,new_pos)
        new_pos = (x, y-1)
        if new_pos[1] > 0:
          if not (position in walls):
            result.graph.addEdge(position,new_pos)
        new_pos = (x, y+1)
        if new_pos[1] < height:
          if not (position in walls):
            result.graph.addEdge(position,new_pos)

proc breadth_first_search_2(g:Grid,start:(int,int)) =
  var frontier: Deque[(int,int)]
  frontier.addLast(start)
  var came_from : Table[(int,int),(int,int)]
  came_from[start] = start
  while not frontier.empty:
    var current = frontier.popFirst 
    for next in g.graph.edges[current]:
            if not (next in came_from):
                frontier.addLast(next)
                came_from[next] = current
