module Evergreen.Migrate.V15 exposing (..)

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

import Evergreen.V14.Direction3dWire
import Evergreen.V14.Types
import Evergreen.V15.Direction3dWire
import Evergreen.V15.Types
import Lamdera.Migrations exposing (..)


frontendModel : Evergreen.V14.Types.FrontendModel -> ModelMigration Evergreen.V15.Types.FrontendModel Evergreen.V15.Types.FrontendMsg
frontendModel old =
    ModelMigrated ( migrate_Types_FrontendModel old, Cmd.none )


backendModel : Evergreen.V14.Types.BackendModel -> ModelMigration Evergreen.V15.Types.BackendModel Evergreen.V15.Types.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Evergreen.V14.Types.FrontendMsg -> MsgMigration Evergreen.V15.Types.FrontendMsg Evergreen.V15.Types.FrontendMsg
frontendMsg old =
    MsgUnchanged


toBackend : Evergreen.V14.Types.ToBackend -> MsgMigration Evergreen.V15.Types.ToBackend Evergreen.V15.Types.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Evergreen.V14.Types.BackendMsg -> MsgMigration Evergreen.V15.Types.BackendMsg Evergreen.V15.Types.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Evergreen.V14.Types.ToFrontend -> MsgMigration Evergreen.V15.Types.ToFrontend Evergreen.V15.Types.FrontendMsg
toFrontend old =
    MsgUnchanged


migrate_Types_FrontendModel : Evergreen.V14.Types.FrontendModel -> Evergreen.V15.Types.FrontendModel
migrate_Types_FrontendModel old =
    { width = old.width
    , height = old.height
    , cameraAngle = old.cameraAngle |> migrate_Direction3dWire_Direction3dWire migrate_Types_RealWorldCoordinates
    , cameraPosition = old.cameraPosition
    , viewAngleDelta = old.viewAngleDelta
    , leftKey = old.leftKey |> migrate_Types_ButtonState
    , rightKey = old.rightKey |> migrate_Types_ButtonState
    , upKey = old.upKey |> migrate_Types_ButtonState
    , downKey = old.downKey |> migrate_Types_ButtonState
    , mouseButtonState = old.mouseButtonState |> migrate_Types_ButtonState
    , touches = old.touches |> migrate_Types_TouchContact
    , joystickPosition = (Unimplemented {- Type `(Float, Float)` was added in V15. I need you to set a default value. -})
    , lightPosition = old.lightPosition
    , lastContact = old.lastContact |> migrate_Types_ContactType
    }


migrate_Direction3dWire_Direction3dWire : (coordinates_old -> coordinates_new) -> Evergreen.V14.Direction3dWire.Direction3dWire coordinates_old -> Evergreen.V15.Direction3dWire.Direction3dWire coordinates_new
migrate_Direction3dWire_Direction3dWire migrate_coordinates old =
    case old of
        Evergreen.V14.Direction3dWire.Direction3dWire p0 p1 p2 ->
            Evergreen.V15.Direction3dWire.Direction3dWire p0 p1 p2


migrate_Types_ButtonState : Evergreen.V14.Types.ButtonState -> Evergreen.V15.Types.ButtonState
migrate_Types_ButtonState old =
    case old of
        Evergreen.V14.Types.Up ->
            Evergreen.V15.Types.Up

        Evergreen.V14.Types.Down ->
            Evergreen.V15.Types.Down


migrate_Types_ContactType : Evergreen.V14.Types.ContactType -> Evergreen.V15.Types.ContactType
migrate_Types_ContactType old =
    case old of
        Evergreen.V14.Types.Touch ->
            Evergreen.V15.Types.Touch

        Evergreen.V14.Types.Mouse ->
            Evergreen.V15.Types.Mouse


migrate_Types_RealWorldCoordinates : Evergreen.V14.Types.RealWorldCoordinates -> Evergreen.V15.Types.RealWorldCoordinates
migrate_Types_RealWorldCoordinates old =
    case old of
        Evergreen.V14.Types.RealWorldCoordinates ->
            Evergreen.V15.Types.RealWorldCoordinates


migrate_Types_TouchContact : Evergreen.V14.Types.TouchContact -> Evergreen.V15.Types.TouchContact
migrate_Types_TouchContact old =
    case old of
        Evergreen.V14.Types.OneFinger p0 ->
            Evergreen.V15.Types.OneFinger p0

        Evergreen.V14.Types.NotOneFinger ->
            Evergreen.V15.Types.NotOneFinger