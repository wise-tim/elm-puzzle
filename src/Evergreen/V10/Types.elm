module Evergreen.V10.Types exposing (..)

import Evergreen.V10.Direction3dWire


type ButtonState
    = Up
    | Down


type RealWorldCoordinates
    = RealWorldCoordinates


type TouchContact
    = OneFinger
        { identifier : Int
        , screenPos : ( Float, Float )
        }
    | NotOneFinger


type alias FrontendModel =
    { width : Float
    , height : Float
    , mouseDelta : ( Float, Float )
    , leftKey : ButtonState
    , rightKey : ButtonState
    , upKey : ButtonState
    , downKey : ButtonState
    , cameraAngle : Evergreen.V10.Direction3dWire.Direction3dWire RealWorldCoordinates
    , cameraPosition : ( Float, Float, Float )
    , mouseButtonState : ButtonState
    , touches : TouchContact
    , lightPosition : ( Float, Float, Float )
    }


type alias BackendModel =
    { message : String
    }


type ArrowKey
    = UpKey
    | DownKey
    | LeftKey
    | RightKey


type FrontendMsg
    = WindowResized Float Float
    | Tick Float
    | MouseMoved Float Float
    | MouseDown
    | MouseUp
    | ArrowKeyChanged ArrowKey ButtonState
    | TouchesChanged TouchContact
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
