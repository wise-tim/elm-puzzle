port module Frontend exposing (app)

import Angle
import Axis3d
import Browser
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Camera3d
import Color
import Cylinder3d
import Direction2d
import Direction3d
import Direction3dWire
import Duration
import Frame3d
import Html
import Html.Attributes
import Html.Events
import Html.Events.Extra.Mouse
import Html.Events.Extra.Touch
import Illuminance
import Json.Decode
import Json.Encode
import Keyboard.Event
import Keyboard.Key
import Lamdera
import Lamdera.Json as Json
import Length
import Luminance
import LuminousFlux
import Pixels
import Plane3d
import Point2d
import Point3d
import Quantity
import Scene3d
import Scene3d.Light
import Scene3d.Material
import Speed
import Sphere3d
import Svg
import Svg.Attributes
import Task
import Types exposing (..)
import Url
import Vector2d
import Vector3d
import Viewpoint3d


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = \_ -> NoOpFrontendMsg
        , onUrlChange = \_ -> NoOpFrontendMsg
        , update = update
        , updateFromBackend = \_ model -> ( model, Cmd.none )
        , subscriptions = subscriptions
        , view = view
        }


init : Url.Url -> Browser.Navigation.Key -> ( Model, Cmd FrontendMsg )
init _ _ =
    let
        handleResult v =
            case v of
                Err _ ->
                    NoOpFrontendMsg

                Ok vp ->
                    WindowResized vp.scene.width vp.scene.height
    in
    ( { width = 0
      , height = 0
      , cameraAngle = Direction3dWire.fromDirection3d (Maybe.withDefault Direction3d.positiveX (Direction3d.from (Point3d.inches 5 -4 2) (Point3d.inches 2 2 2)))
      , cameraPosition = ( 5, -4, 2 )
      , mouseButtonState = Up
      , leftKey = Up
      , rightKey = Up
      , upKey = Up
      , downKey = Up
      , joystickPosition = ( 0, 0 )
      , viewAngleDelta = ( 0, 0 )
      , lightPosition = ( 3, 3, 3 )
      , touches = NotOneFinger
      , lastContact = Mouse
      , pointerCapture = PointerNotLocked
      }
    , Task.attempt handleResult Browser.Dom.getViewport
    )


type PlayerCoordinates
    = PlayerCoordinates


cameraFrame3d :
    Point3d.Point3d Length.Meters RealWorldCoordinates
    -> Direction3d.Direction3d RealWorldCoordinates
    -> Maybe (Frame3d.Frame3d Length.Meters RealWorldCoordinates { defines : PlayerCoordinates })
cameraFrame3d position angle =
    let
        globalUp =
            Direction3d.toVector Direction3d.positiveZ

        globalforward =
            Direction3d.toVector angle

        globalLeft =
            Vector3d.cross globalUp globalforward
    in
    Direction3d.orthonormalize globalforward globalUp globalLeft
        |> Maybe.map
            (\( playerForward, playerUp, playerLeft ) ->
                Frame3d.unsafe
                    { originPoint = position
                    , xDirection = playerLeft
                    , yDirection = playerForward
                    , zDirection = playerUp
                    }
            )


playerSpeed =
    Speed.metersPerSecond 10


update : FrontendMsg -> Model -> ( Model, Cmd msg )
update msg model =
    case ( msg, model.pointerCapture ) of
        ( WindowResized w h, _ ) ->
            ( { model | width = w, height = h }, Cmd.none )

        ( Tick tickMilliseconds, _ ) ->
            if inputsUnchanged model then
                ( model, Cmd.none )

            else
                let
                    tickDuration =
                        Duration.milliseconds tickMilliseconds

                    ( x, y, z ) =
                        model.cameraPosition

                    positionPoint =
                        Point3d.meters x y z

                    cameraAngle =
                        Direction3dWire.toDirection3d model.cameraAngle
                in
                cameraFrame3d positionPoint cameraAngle
                    |> Maybe.map
                        (\playerFrame ->
                            let
                                newCameraPosition =
                                    let
                                        ( px, py ) =
                                            model.joystickPosition

                                        unitDistance =
                                            Quantity.for tickDuration playerSpeed
                                    in
                                    Maybe.map2
                                        (\leftDirection forwardDirection ->
                                            Vector3d.plus
                                                (leftDirection |> Vector3d.withLength (Quantity.multiplyBy px unitDistance))
                                                (forwardDirection |> Vector3d.withLength (Quantity.multiplyBy -py unitDistance))
                                        )
                                        (Frame3d.xDirection playerFrame |> Direction3d.projectOnto Plane3d.xy)
                                        (Frame3d.yDirection playerFrame |> Direction3d.projectOnto Plane3d.xy)
                                        |> Maybe.map
                                            (\movement ->
                                                positionPoint |> Point3d.translateBy movement |> Point3d.toTuple Length.inMeters
                                            )
                                        |> Maybe.withDefault model.cameraPosition

                                ( dx, dy ) =
                                    model.viewAngleDelta

                                newAngle =
                                    playerFrame
                                        |> Frame3d.rotateAroundOwn Frame3d.zAxis (Angle.radians (-0.004 * dx))
                                        |> Frame3d.rotateAroundOwn Frame3d.xAxis (Angle.radians (-0.004 * dy))
                                        |> Frame3d.yDirection
                            in
                            ( { model
                                | cameraPosition = newCameraPosition
                                , cameraAngle = Direction3dWire.fromDirection3d newAngle
                                , viewAngleDelta = ( 0, 0 )
                              }
                            , Cmd.none
                            )
                        )
                    |> Maybe.withDefault ( model, Cmd.none )

        ( MouseMoved x y, PointerLocked ) ->
            ( { model
                | viewAngleDelta =
                    case model.viewAngleDelta of
                        ( a, b ) ->
                            ( a + x, b + y )
                , lastContact = Mouse
              }
            , Cmd.none
            )

        ( MouseMoved _ _, _ ) ->
            ( model
            , Cmd.none
            )

        ( MouseDown, _ ) ->
            ( { model | mouseButtonState = Down, lastContact = Mouse }, pointerLock Json.Encode.null )

        ( MouseUp, _ ) ->
            ( { model | mouseButtonState = Up, lastContact = Mouse }, Cmd.none )

        ( ArrowKeyChanged key state, _ ) ->
            let
                newModel =
                    case key of
                        UpKey ->
                            { model | upKey = state }

                        DownKey ->
                            { model | downKey = state }

                        LeftKey ->
                            { model | leftKey = state }

                        RightKey ->
                            { model | rightKey = state }

                newJoystickX =
                    case ( newModel.leftKey, newModel.rightKey ) of
                        ( Up, Down ) ->
                            1

                        ( Down, Up ) ->
                            -1

                        _ ->
                            0

                newJoystickY =
                    case ( newModel.upKey, newModel.downKey ) of
                        ( Up, Down ) ->
                            1

                        ( Down, Up ) ->
                            -1

                        _ ->
                            0

                newXY =
                    case Direction2d.from Point2d.origin (Point2d.fromUnitless { x = newJoystickX, y = newJoystickY }) of
                        Just direction ->
                            direction |> Direction2d.toVector |> Vector2d.toTuple Quantity.toFloat

                        Nothing ->
                            ( 0, 0 )
            in
            ( { newModel | joystickPosition = newXY }, Cmd.none )

        ( TouchesChanged contact, _ ) ->
            let
                zeroDelta =
                    ( 0, 0 )

                delta =
                    case ( model.touches, contact ) of
                        ( OneFinger old, OneFinger new ) ->
                            if old.identifier == new.identifier then
                                tupleSubtract new.screenPos old.screenPos

                            else
                                zeroDelta

                        _ ->
                            zeroDelta

                totalDelta =
                    tupleAdd delta model.viewAngleDelta
            in
            ( { model | touches = contact, viewAngleDelta = totalDelta, lastContact = Touch }, Cmd.none )

        ( JoystickTouchChanged contact, _ ) ->
            let
                newJoystickPosition =
                    case contact of
                        OneFinger { screenPos } ->
                            case ( joystickOrigin model.height, screenPos ) of
                                ( ( jx, jy ), ( sx, sy ) ) ->
                                    let
                                        newX =
                                            (sx - jx) / joystickFreedom

                                        newY =
                                            (sy - jy) / joystickFreedom

                                        vector =
                                            Vector2d.unitless newX newY
                                    in
                                    if Quantity.toFloat (Vector2d.length vector) > 1 then
                                        case Vector2d.direction vector |> Maybe.map Direction2d.unwrap of
                                            Just { x, y } ->
                                                ( x, y )

                                            Nothing ->
                                                ( 0, 0 )

                                    else
                                        ( newX, newY )

                        NotOneFinger ->
                            ( 0, 0 )
            in
            ( { model | lastContact = Touch, joystickPosition = newJoystickPosition }, Cmd.none )

        ( ShootClicked, _ ) ->
            ( model, Cmd.none )

        ( GotPointerLock, _ ) ->
            ( { model | pointerCapture = PointerLocked }, Cmd.none )

        ( LostPointerLock, _ ) ->
            ( { model | pointerCapture = PointerNotLocked }, Cmd.none )

        ( NoOpFrontendMsg, _ ) ->
            ( model, Cmd.none )


tupleSubtract a b =
    case ( a, b ) of
        ( ( a1, a2 ), ( b1, b2 ) ) ->
            ( a1 - b1, a2 - b2 )


tupleAdd a b =
    case ( a, b ) of
        ( ( a1, a2 ), ( b1, b2 ) ) ->
            ( a1 + b1, a2 + b2 )


inputsUnchanged { viewAngleDelta, joystickPosition } =
    (case viewAngleDelta of
        ( dx, dy ) ->
            Basics.abs dx < 0.0001 && Basics.abs dy < 0.0001
    )
        && (case joystickPosition of
                ( dx, dy ) ->
                    Basics.abs dx < 0.0001 && Basics.abs dy < 0.0001
           )


toTouchMsg : Html.Events.Extra.Touch.Event -> TouchContact
toTouchMsg e =
    case e.targetTouches of
        [ touch ] ->
            OneFinger
                { identifier = touch.identifier
                , screenPos = touch.clientPos
                }

        _ ->
            NotOneFinger


joystickOrigin height =
    ( 130, height - 70 )


joystickSize =
    20


joystickFreedom =
    40


shootButtonLocation width height =
    ( width - 100, height - 200 )


view : Model -> Browser.Document FrontendMsg
view { width, height, cameraAngle, cameraPosition, lightPosition, lastContact, joystickPosition, pointerCapture } =
    { title = "Hello"
    , body =
        [ Html.div
            [ Html.Attributes.style "position" "fixed"
            ]
            [ Scene3d.custom
                (let
                    lightPoint =
                        case lightPosition of
                            ( x, y, z ) ->
                                Point3d.inches x y z
                 in
                 { lights =
                    Scene3d.twoLights
                        (Scene3d.Light.point (Scene3d.Light.castsShadows True)
                            { chromaticity = Scene3d.Light.incandescent
                            , intensity = LuminousFlux.lumens 50000
                            , position = lightPoint
                            }
                        )
                        (Scene3d.Light.ambient
                            { chromaticity = Scene3d.Light.incandescent
                            , intensity = Illuminance.lux 30000
                            }
                        )
                 , camera =
                    Camera3d.perspective
                        { viewpoint =
                            case cameraPosition of
                                ( x, y, z ) ->
                                    Viewpoint3d.lookAt
                                        { eyePoint =
                                            Point3d.inches x y z
                                        , focalPoint =
                                            Point3d.translateIn
                                                (Direction3dWire.toDirection3d cameraAngle)
                                                (Quantity.Quantity 1)
                                                (Point3d.inches x y z)
                                        , upDirection = Direction3d.positiveZ
                                        }
                        , verticalFieldOfView = Angle.degrees 45
                        }
                 , clipDepth = Length.centimeters 0.5
                 , exposure = Scene3d.exposureValue 15
                 , toneMapping = Scene3d.hableFilmicToneMapping
                 , whiteBalance = Scene3d.Light.incandescent
                 , antialiasing = Scene3d.multisampling
                 , dimensions = ( Pixels.int (round width), Pixels.int (round height) )
                 , background = Scene3d.backgroundColor (Color.fromRgba { red = 0.17, green = 0.17, blue = 0.19, alpha = 1 })
                 , entities =
                    List.concat
                        [ [ lightEntity |> Scene3d.translateBy (Vector3d.fromTuple Length.inches lightPosition)
                          ]
                        , staticEntities
                        ]
                 }
                )
            ]
        , Html.div
            [ Html.Attributes.id "overlay-div"
            , Html.Attributes.style "position" "fixed"
            , Html.Events.custom "mousemove"
                (case pointerCapture of
                    PointerNotLocked ->
                        Json.Decode.fail "Mouse is not captured"

                    PointerLocked ->
                        Json.Decode.map2
                            (\a b -> { message = MouseMoved a b, preventDefault = True, stopPropagation = False })
                            (Json.Decode.field "movementX" Json.Decode.float)
                            (Json.Decode.field "movementY" Json.Decode.float)
                )
            , Html.Events.onMouseDown MouseDown
            , Html.Events.onMouseUp MouseUp
            , Html.Events.Extra.Touch.onWithOptions "touchstart"
                { preventDefault = True, stopPropagation = True }
                (\event -> TouchesChanged (toTouchMsg event))
            , Html.Events.Extra.Touch.onWithOptions "touchmove"
                { preventDefault = True, stopPropagation = True }
                (\event -> TouchesChanged (toTouchMsg event))
            , Html.Events.Extra.Touch.onWithOptions "touchend"
                { preventDefault = True, stopPropagation = True }
                (\event -> TouchesChanged (toTouchMsg event))
            ]
            [ Svg.svg
                [ Svg.Attributes.width (String.fromFloat width)
                , Svg.Attributes.height (String.fromFloat height)
                , Svg.Attributes.viewBox ("0 0 " ++ String.fromFloat width ++ " " ++ String.fromFloat height)
                ]
                (case lastContact of
                    Touch ->
                        case joystickOrigin height of
                            ( cx, cy ) ->
                                [ case joystickPosition of
                                    ( px, py ) ->
                                        Svg.circle
                                            [ Svg.Attributes.cx (String.fromFloat (cx + px * joystickFreedom))
                                            , Svg.Attributes.cy (String.fromFloat (cy + py * joystickFreedom))
                                            , Svg.Attributes.r (String.fromFloat joystickSize)
                                            , Svg.Attributes.fill (Color.toCssString (Color.fromRgba { red = 0, blue = 0, green = 0, alpha = 0.2 }))
                                            ]
                                            []
                                , Svg.circle
                                    [ Svg.Attributes.cx (String.fromFloat cx)
                                    , Svg.Attributes.cy (String.fromFloat cy)
                                    , Svg.Attributes.r (String.fromFloat (joystickFreedom + joystickSize / 2))
                                    , Svg.Attributes.fill (Color.toCssString (Color.fromRgba { red = 0, blue = 0, green = 0, alpha = 0.2 }))
                                    , Html.Events.Extra.Touch.onWithOptions "touchstart"
                                        { preventDefault = True, stopPropagation = True }
                                        (\event -> JoystickTouchChanged (toTouchMsg event))
                                    , Html.Events.Extra.Touch.onWithOptions "touchmove"
                                        { preventDefault = True, stopPropagation = True }
                                        (\event -> JoystickTouchChanged (toTouchMsg event))
                                    , Html.Events.Extra.Touch.onWithOptions "touchend"
                                        { preventDefault = True, stopPropagation = True }
                                        (\event -> JoystickTouchChanged (toTouchMsg event))
                                    ]
                                    []
                                , case shootButtonLocation width height of
                                    ( bx, by ) ->
                                        Svg.circle
                                            [ Svg.Attributes.cx (String.fromFloat bx)
                                            , Svg.Attributes.cy (String.fromFloat by)
                                            , Svg.Attributes.r (String.fromFloat joystickSize)
                                            , Svg.Attributes.fill (Color.toCssString (Color.fromRgba { red = 0, blue = 0, green = 0, alpha = 0.2 }))
                                            , Html.Events.onClick ShootClicked
                                            ]
                                            []
                                ]

                    Mouse ->
                        []
                )
            ]
        ]
    }


lightEntity =
    Sphere3d.atPoint
        (Point3d.inches 0 0 0)
        (Length.inches
            0.1
        )
        |> Scene3d.sphere
            (Scene3d.Material.emissive
                Scene3d.Light.incandescent
                (Luminance.nits
                    100000
                )
            )


worldSize =
    64


staticEntities =
    [ Cylinder3d.from
        Point3d.origin
        (Point3d.inches 0 0 1)
        (Length.inches
            0.5
        )
        |> Maybe.map
            (Scene3d.cylinderWithShadow
                (Scene3d.Material.matte Color.blue)
            )
        |> Maybe.withDefault Scene3d.nothing
    , Cylinder3d.from
        (Point3d.inches 2 2 0.5)
        (Point3d.inches 2 2 1)
        (Length.inches
            0.5
        )
        |> Maybe.map
            (Scene3d.cylinderWithShadow
                (Scene3d.Material.matte Color.gray)
            )
        |> Maybe.withDefault Scene3d.nothing
    , Scene3d.quad (Scene3d.Material.matte Color.blue)
        (Point3d.inches -worldSize -worldSize 0)
        (Point3d.inches worldSize -worldSize 0)
        (Point3d.inches worldSize worldSize 0)
        (Point3d.inches -worldSize worldSize 0)
    ]


handleArrowKey : Keyboard.Event.KeyboardEvent -> Maybe ArrowKey
handleArrowKey { altKey, ctrlKey, keyCode, metaKey, repeat, shiftKey } =
    if not (altKey || ctrlKey || metaKey || shiftKey || repeat) then
        case keyCode of
            Keyboard.Key.A ->
                Just LeftKey

            Keyboard.Key.Left ->
                Just LeftKey

            Keyboard.Key.D ->
                Just RightKey

            Keyboard.Key.Right ->
                Just RightKey

            Keyboard.Key.S ->
                Just DownKey

            Keyboard.Key.Down ->
                Just DownKey

            Keyboard.Key.W ->
                Just UpKey

            Keyboard.Key.Up ->
                Just UpKey

            _ ->
                Nothing

    else
        Nothing


subscriptions : Model -> Sub FrontendMsg
subscriptions model =
    Sub.batch
        [ Browser.Events.onResize (\x y -> WindowResized (toFloat x) (toFloat y))
        , Browser.Events.onKeyDown
            (Keyboard.Event.considerKeyboardEvent
                (\event -> Maybe.map (\key -> ArrowKeyChanged key Down) (handleArrowKey event))
            )
        , Browser.Events.onKeyUp
            (Keyboard.Event.considerKeyboardEvent
                (\event -> Maybe.map (\key -> ArrowKeyChanged key Up) (handleArrowKey event))
            )
        , Browser.Events.onAnimationFrameDelta
            (\milliseconds ->
                Tick milliseconds
            )
        , gotPointerLock
            (\value ->
                case value |> Json.decodeValue (Json.Decode.field "msg" Json.Decode.string) of
                    Ok "GotPointerLock" ->
                        GotPointerLock

                    Ok "LostPointerLock" ->
                        LostPointerLock

                    Ok _ ->
                        NoOpFrontendMsg

                    Err _ ->
                        NoOpFrontendMsg
            )
        ]


port pointerLock : Json.Encode.Value -> Cmd msg


port gotPointerLock : (Json.Decode.Value -> msg) -> Sub msg
