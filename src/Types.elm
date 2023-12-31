module Types exposing (..)

import Direction3dWire exposing (Direction3dWire)


type ButtonState
    = Up
    | Down


type RealWorldCoordinates
    = RealWorldCoordinates


type TouchContact
    = OneFinger { identifier : Int, screenPos : ( Float, Float ) }
    | NotOneFinger


type PointerCapture
    = PointerLocked
    | PointerNotLocked


type alias FrontendModel =
    { width : Float
    , height : Float
    , cameraAngle : Direction3dWire RealWorldCoordinates
    , cameraPosition : ( Float, Float, Float )
    , viewAngleDelta : ( Float, Float )
    , leftKey : ButtonState
    , rightKey : ButtonState
    , upKey : ButtonState
    , downKey : ButtonState
    , mouseButtonState : ButtonState
    , touches : TouchContact
    , joystickPosition : ( Float, Float )
    , lightPosition : ( Float, Float, Float )
    , lastContact : ContactType
    , pointerCapture : PointerCapture
    }


type ContactType
    = Touch
    | Mouse


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
    | JoystickTouchChanged TouchContact
    | ShootClicked
    | GotPointerLock
    | LostPointerLock
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
