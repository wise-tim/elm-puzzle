module Evergreen.Migrate.V10 exposing (..)

{-| This migration file was automatically generated by the lamdera compiler.

It includes:

  - A migration for each of the 6 Lamdera core types that has changed
  - A function named `migrate_ModuleName_TypeName` for each changed/custom type

Expect to see:

  - `Unimplementеd` values as placeholders wherever I was unable to figure out a clear migration path for you
  - `@NOTICE` comments for things you should know about, i.e. new custom type constructors that won't get any
    value mappings from the old type by default

You can edit this file however you wish! It won't be generated again.

See <https://dashboard.lamdera.com/docs/evergreen> for more info.

-}

import Evergreen.V10.Direction3dWire
import Evergreen.V10.Types
import Evergreen.V4.Direction3dWire
import Evergreen.V4.Types
import Lamdera.Migrations exposing (..)
import Types exposing (TouchContact(..))


frontendModel : Evergreen.V4.Types.FrontendModel -> ModelMigration Evergreen.V10.Types.FrontendModel Evergreen.V10.Types.FrontendMsg
frontendModel old =
    ModelMigrated ( migrate_Types_FrontendModel old, Cmd.none )


backendModel : Evergreen.V4.Types.BackendModel -> ModelMigration Evergreen.V10.Types.BackendModel Evergreen.V10.Types.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Evergreen.V4.Types.FrontendMsg -> MsgMigration Evergreen.V10.Types.FrontendMsg Evergreen.V10.Types.FrontendMsg
frontendMsg old =
    MsgMigrated ( migrate_Types_FrontendMsg old, Cmd.none )


toBackend : Evergreen.V4.Types.ToBackend -> MsgMigration Evergreen.V10.Types.ToBackend Evergreen.V10.Types.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Evergreen.V4.Types.BackendMsg -> MsgMigration Evergreen.V10.Types.BackendMsg Evergreen.V10.Types.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Evergreen.V4.Types.ToFrontend -> MsgMigration Evergreen.V10.Types.ToFrontend Evergreen.V10.Types.FrontendMsg
toFrontend old =
    MsgUnchanged


migrate_Types_FrontendModel : Evergreen.V4.Types.FrontendModel -> Evergreen.V10.Types.FrontendModel
migrate_Types_FrontendModel old =
    { width = old.width
    , height = old.height
    , mouseDelta = ( 0, 0 )
    , leftKey = old.leftKey |> migrate_Types_ButtonState
    , rightKey = old.rightKey |> migrate_Types_ButtonState
    , upKey = old.upKey |> migrate_Types_ButtonState
    , downKey = old.downKey |> migrate_Types_ButtonState
    , cameraAngle = old.cameraAngle |> migrate_Direction3dWire_Direction3dWire migrate_Types_RealWorldCoordinates
    , cameraPosition = old.cameraPosition
    , mouseButtonState = old.mouseButtonState |> migrate_Types_ButtonState
    , touches = Evergreen.V10.Types.NotOneFinger
    , lightPosition = old.lightPosition
    }


migrate_Direction3dWire_Direction3dWire : (coordinates_old -> coordinates_new) -> Evergreen.V4.Direction3dWire.Direction3dWire coordinates_old -> Evergreen.V10.Direction3dWire.Direction3dWire coordinates_new
migrate_Direction3dWire_Direction3dWire migrate_coordinates old =
    case old of
        Evergreen.V4.Direction3dWire.Direction3dWire p0 p1 p2 ->
            Evergreen.V10.Direction3dWire.Direction3dWire p0 p1 p2


migrate_Types_ArrowKey : Evergreen.V4.Types.ArrowKey -> Evergreen.V10.Types.ArrowKey
migrate_Types_ArrowKey old =
    case old of
        Evergreen.V4.Types.UpKey ->
            Evergreen.V10.Types.UpKey

        Evergreen.V4.Types.DownKey ->
            Evergreen.V10.Types.DownKey

        Evergreen.V4.Types.LeftKey ->
            Evergreen.V10.Types.LeftKey

        Evergreen.V4.Types.RightKey ->
            Evergreen.V10.Types.RightKey


migrate_Types_ButtonState : Evergreen.V4.Types.ButtonState -> Evergreen.V10.Types.ButtonState
migrate_Types_ButtonState old =
    case old of
        Evergreen.V4.Types.Up ->
            Evergreen.V10.Types.Up

        Evergreen.V4.Types.Down ->
            Evergreen.V10.Types.Down


migrate_Types_FrontendMsg : Evergreen.V4.Types.FrontendMsg -> Evergreen.V10.Types.FrontendMsg
migrate_Types_FrontendMsg old =
    case old of
        Evergreen.V4.Types.WindowResized p0 p1 ->
            Evergreen.V10.Types.WindowResized p0 p1

        Evergreen.V4.Types.Tick p0 ->
            Evergreen.V10.Types.Tick p0

        Evergreen.V4.Types.MouseMoved p0 p1 ->
            Evergreen.V10.Types.MouseMoved p0 p1

        Evergreen.V4.Types.MouseDown ->
            Evergreen.V10.Types.MouseDown

        Evergreen.V4.Types.MouseUp ->
            Evergreen.V10.Types.MouseUp

        Evergreen.V4.Types.ArrowKeyChanged p0 p1 ->
            Evergreen.V10.Types.ArrowKeyChanged (p0 |> migrate_Types_ArrowKey)
                (p1 |> migrate_Types_ButtonState)

        Evergreen.V4.Types.NoOpFrontendMsg ->
            Evergreen.V10.Types.NoOpFrontendMsg


migrate_Types_RealWorldCoordinates : Evergreen.V4.Types.RealWorldCoordinates -> Evergreen.V10.Types.RealWorldCoordinates
migrate_Types_RealWorldCoordinates old =
    case old of
        Evergreen.V4.Types.RealWorldCoordinates ->
            Evergreen.V10.Types.RealWorldCoordinates
