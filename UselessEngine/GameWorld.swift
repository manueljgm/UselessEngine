//
//  PhysicsWorld.swift
//  UselessEngine
//
//  Created by Manny Martins on 12/15/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public class GameWorld
{
    public let gridDimensions: (width: Int, height: Int)
    public let gridSpacing: Vector2d
    public let gravity: Float // meters per second per second

    public private(set) var allObjects: ContiguousArray<GameEntity>
    public private(set) var tilesByGridPosition: [UnitPosition: GameTile]
    public private(set) var contactingObjectsByGridPosition: [UnitPosition: [GameObject]]
    public private(set) var contactedCornersByGameObject: [UUID: (bottomLeft: UnitPosition, topRight: UnitPosition)]
    
    private let collisionDelegate: GameWorldCollisionDelegate
    
    // MARK: - Init
    
    /// Initializes a game world.
    public init(gridDimensions: (width: Int, height: Int),
                gridSpacing: Vector2d,
                gravity: Float,
                collisionDelegate: GameWorldCollisionDelegate)
    {
        self.gridDimensions = gridDimensions
        self.gridSpacing = gridSpacing
        self.gravity = gravity

        self.allObjects = []
        self.tilesByGridPosition = [:]
        self.contactingObjectsByGridPosition = [:]
        for y in 0...gridDimensions.height-1 {
            for x in 0...gridDimensions.width-1 {
                self.contactingObjectsByGridPosition[UnitPosition(x: x, y: y)] = []
            }
        }
        self.contactedCornersByGameObject = [:]
        
        self.collisionDelegate = collisionDelegate
        
        #if DEBUG_VERBOSE
        print("GameWorld:init")
        #endif
    }

    deinit {
        #if DEBUG_VERBOSE
        print("GameWorld:deinit")
        #endif
    }
    
    // MARK: - Object Management
    
    public func add(tile gameTile: GameTile)
    {
        let gridX = Int(floor(gameTile.position.x / gridSpacing.dx))
        let gridY = Int(floor(gameTile.position.y / gridSpacing.dy))
        let gridPosition = UnitPosition(x: gridX, y: gridY)
        
        allObjects.append(gameTile)
        
        // associate tile to grid position
        tilesByGridPosition[gridPosition] = gameTile
        
        #if DEBUG_VERBOSE
        print("GameTile added to GameWorld.")
        #endif
    }
    
    public func add(gameObject: GameObject)
    {
        allObjects.append(gameObject)

        // associate game object to touched grid positions
        updateContactedCorners(for: gameObject)
        
        #if DEBUG_VERBOSE
        print("GameObject added to GameWorld.")
        #endif
    }
    
    public func gridPosition(from position: Position) -> UnitPosition
    {
        return UnitPosition(x: Int(floor(position.x / gridSpacing.dx)),
                            y: Int(floor(position.y / gridSpacing.dy)))
    }
    
    public func elevation(atPosition position: PlaneCoordinate) -> Float
    {
        guard let tile = tile(atPosition: position) else {
            return 0.0
        }
        
        return tile.elevation.getElevation(atPoint: position - tile.position)
    }
    
    // MARK: - Update Loop

    public func update(_ dt: Float)
    {
        // update all world objects
        allObjects.forEach { worldObject in
            // update world object
            let observedChanges = worldObject.update(dt)
            if observedChanges.contains(.position) {
                if let gameObject = worldObject as? GameObject
                {
                    // keep game object within the world's boundaries
                    collisionDelegate.resolveBoundaries(on: gameObject, in: self)
                    
                    // update game object's contact position
                    updateContactedCorners(for: gameObject)
                }
            }
        }
        
        // resolve any collisions
        contactingObjectsByGridPosition.values.forEach { gameObjects in
            guard gameObjects.count > 1 else {
                return
            }

            gameObjects.forEach { gameObject in
                let hitObjects = collisionDelegate.resolveCollisions(on: gameObject, in: self)
                hitObjects.forEach {
                    updateContactedCorners(for: $0)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func tile(atGridPosition gridPosition: UnitPosition) -> GameTile? {
        return tilesByGridPosition[gridPosition]
    }
    
    private func tile(atGridPositionX x: Int, Y y: Int) -> GameTile? {
        return tilesByGridPosition[UnitPosition(x: x, y: y)]
    }
    
    private func tile(atPosition position: PlaneCoordinate) -> GameTile?
    {
        let gridPosition = UnitPosition(x: Int(position.x / gridSpacing.dx),
                                        y: Int(position.y / gridSpacing.dy))
        
        return tile(atGridPosition: gridPosition)
    }
    
    private func gridCorners(containing boundingBox: AABB, withMarginFactor marginFactor: Float) -> (bottomLeft: UnitPosition, topRight: UnitPosition)
    {
        // calculate bottom left grid corner contain with padding
        let bottomLeftX = ((boundingBox.centerPosition.x - boundingBox.halfwidths.dx) / gridSpacing.dx) - marginFactor
        let bottomLeftY = ((boundingBox.centerPosition.y - boundingBox.halfwidths.dy) / gridSpacing.dy) - marginFactor
        let bottomLeftCorner = UnitPosition(x: Int(floor(bottomLeftX)), y: Int(floor(bottomLeftY)))

        // calculate top right contacted grid corner with padding
        let topRightX = ((boundingBox.centerPosition.x + boundingBox.halfwidths.dx) / gridSpacing.dx) + marginFactor
        let topRightY = ((boundingBox.centerPosition.y + boundingBox.halfwidths.dy) / gridSpacing.dy) + marginFactor
        let topRightCorner = UnitPosition(x: Int(floor(topRightX)), y: Int(floor(topRightY)))

        return (bottomLeftCorner, topRightCorner)
    }
    
    private func gridPositionList(from bottomLeft: UnitPosition, to topRight: UnitPosition) -> [UnitPosition] {
        guard bottomLeft.x <= topRight.x && bottomLeft.y <= topRight.y else {
            return []
        }
        
        var gridPositions: [UnitPosition] = []
        (bottomLeft.y...topRight.y).forEach { y in
            (bottomLeft.x...topRight.x).forEach { x in
                gridPositions.append(UnitPosition(x: x, y: y))
            }
        }
        
        return gridPositions
    }
    
    private func updateContactedCorners(for gameObject: GameObject)
    {
        guard let gameObjectCollisionDelegate = gameObject.physics?.collisionDelegate else {
            return
        }
        
        let previouslyContactedCorners = contactedCornersByGameObject[gameObject.id] ?? (.zero, .zero)
        let contactingCorners = gridCorners(containing: gameObjectCollisionDelegate.contactAABB, withMarginFactor: 0.5)
        if previouslyContactedCorners == contactingCorners {
            return
        }

        // update indication of game object's contact with these grid positions
        let removals = gridPositionList(from: previouslyContactedCorners.bottomLeft, to: previouslyContactedCorners.topRight)
        removals.forEach { gridPosition in
            contactingObjectsByGridPosition[gridPosition] = contactingObjectsByGridPosition[gridPosition]?.filter { $0 != gameObject} ?? []
        }
        let additions = gridPositionList(from: contactingCorners.bottomLeft, to: contactingCorners.topRight)
        additions.forEach { gridPosition in
            if contactingObjectsByGridPosition[gridPosition]?.first(where: { $0 == gameObject }) == nil {
                contactingObjectsByGridPosition[gridPosition]?.append(gameObject)
            }
        }
        
        // update contacted corners
        contactedCornersByGameObject[gameObject.id] = contactingCorners
    }
        
}
