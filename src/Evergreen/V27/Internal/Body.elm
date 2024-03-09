module Evergreen.V27.Internal.Body exposing (..)

import Evergreen.V27.Internal.Material
import Evergreen.V27.Internal.Matrix3
import Evergreen.V27.Internal.Shape
import Evergreen.V27.Internal.Transform3d
import Evergreen.V27.Internal.Vector3
import Evergreen.V27.Physics.Coordinates


type alias Body data =
    { id : Int
    , data : data
    , material : Evergreen.V27.Internal.Material.Material
    , transform3d :
        Evergreen.V27.Internal.Transform3d.Transform3d
            Evergreen.V27.Physics.Coordinates.WorldCoordinates
            { defines : Evergreen.V27.Internal.Shape.CenterOfMassCoordinates
            }
    , centerOfMassTransform3d :
        Evergreen.V27.Internal.Transform3d.Transform3d
            Evergreen.V27.Physics.Coordinates.BodyCoordinates
            { defines : Evergreen.V27.Internal.Shape.CenterOfMassCoordinates
            }
    , velocity : Evergreen.V27.Internal.Vector3.Vec3
    , angularVelocity : Evergreen.V27.Internal.Vector3.Vec3
    , mass : Float
    , shapes : List (Evergreen.V27.Internal.Shape.Shape Evergreen.V27.Internal.Shape.CenterOfMassCoordinates)
    , worldShapes : List (Evergreen.V27.Internal.Shape.Shape Evergreen.V27.Physics.Coordinates.WorldCoordinates)
    , force : Evergreen.V27.Internal.Vector3.Vec3
    , torque : Evergreen.V27.Internal.Vector3.Vec3
    , boundingSphereRadius : Float
    , linearDamping : Float
    , angularDamping : Float
    , invMass : Float
    , invInertia : Evergreen.V27.Internal.Matrix3.Mat3
    , invInertiaWorld : Evergreen.V27.Internal.Matrix3.Mat3
    }
