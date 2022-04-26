import std/[sequtils, algorithm, sets]

import shade

import grid as gridModule

type GameLayer* = ref object of Layer
  grid: Grid
  colliders: HashSet[PhysicsBody]

proc newGameLayer*(grid: Grid): GameLayer =
  result = GameLayer()
  initLayer(Layer(result))
  result.grid = grid
  result.colliders = initHashSet[PhysicsBody]()

method visitChildren*(this: GameLayer, handler: proc(child: Node)) =
  var childrenSeq = this.childIterator.toSeq
  childrenSeq.sort do (a, b: Node) -> int:
    return cmp(a.y, b.y)

  for child in childrenSeq:
    handler(child)

proc resolveCollision(this: GameLayer, bodyA, bodyB: PhysicsBody) =
  let
    collisionResult = collides(
      bodyA.getLocation(),
      bodyA.collisionShape,
      bodyB.getLocation(),
      bodyB.collisionShape
    )

  if collisionResult != nil:
    bodyA.move(collisionResult.getMinimumTranslationVector())

    bodyA.notifyCollisionListeners(bodyB, collisionResult, VECTOR_ZERO)
    bodyB.notifyCollisionListeners(bodyA, collisionResult.invert(), VECTOR_ZERO)

method update*(this: GameLayer, deltaTime: float, onChildUpdate: proc(child: Node) = nil) =
  procCall Layer(this).update(deltaTime, onChildUpdate)

  for child in this.childIterator:
    if child of PhysicsBody:
      let 
        body = PhysicsBody(child)
        bounds = body.getBounds()

      if bounds != nil and body.kind != PhysicsBodyKind.STATIC:
        for (x, y) in this.grid.findOverlappingTiles(bounds):
          for bodyInGrid in this.grid[x, y]:
            if body != bodyInGrid:
              this.colliders.incl(bodyInGrid)

        for collider in this.colliders:
          this.resolveCollision(body, collider)

        this.colliders.clear()
