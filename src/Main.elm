module Main exposing (Model, Msg(..), main)

import Browser
import Browser.Events exposing (onResize)
import Html exposing (Html, div, text)
import Html.Attributes as Attr
import InteropDefinitions exposing (FromElm(..), ScreenSize(..), ToElm(..))
import InteropPorts exposing (decodeFlags, fromElm, toElm)
import Json.Decode as Decode


main : Program Decode.Value Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


initialModel : Model
initialModel =
    { size = Mobile 320 640
    }


type alias Model =
    { size : ScreenSize
    }


type Msg
    = NoOp
    | ToElm (Result Decode.Error InteropDefinitions.ToElm)
    | Resize Int Int


{-| An update function for messages coming from JS.
-}
handleToElmMsg : ToElm -> Model -> ( Model, Cmd Msg )
handleToElmMsg toElmMsg model =
    case toElmMsg of
        ToElmNoOp ->
            update NoOp model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ToElm decodeResult ->
            case decodeResult of
                Ok toElmMsg ->
                    handleToElmMsg toElmMsg model

                Err _ ->
                    ( model, Cmd.none )

        Resize w h ->
            ( { model | size = dimensionsToSize w h }, Cmd.none )


dimensionsToSize : Int -> Int -> ScreenSize
dimensionsToSize w h =
    if w < 1024 then
        Mobile w h

    else
        Desktop w h


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ Sub.map ToElm toElm, onResize Resize ]


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    case decodeFlags flags of
        Ok _ ->
            ( initialModel, AppInit |> fromElm )

        Err _ ->
            ( initialModel
            , Cmd.none
            )


view : Model -> Html Msg
view _ =
    div [ Attr.class "w-5/6 m-auto" ]
        [ text "Hello, world!" ]
