module InteropDefinitions exposing (Flags, FromElm(..), ScreenSize(..), ToElm(..), interop)

import TsJson.Decode as TsDecode exposing (Decoder)
import TsJson.Encode as TsEncode exposing (Encoder)


interop :
    { toElm : Decoder ToElm
    , fromElm : Encoder FromElm
    , flags : Decoder Flags
    }
interop =
    { toElm = toElm
    , fromElm = fromElm
    , flags = flagsDecoder
    }


{-| Messages that application can send to Javascript.
-}
type FromElm
    = AppInit


{-| Messages that application can receive from Javascript.
-}
type ToElm
    = ToElmNoOp


type alias Flags =
    { initialScreenSize : ScreenSize
    , url : String
    }


type ScreenSize
    = Mobile Int Int
    | Table Int Int
    | Desktop Int Int


fromElm : Encoder FromElm
fromElm =
    TsEncode.union
        (\vAppInit msg ->
            case msg of
                AppInit ->
                    vAppInit
        )
        |> TsEncode.variant0 "APP_INIT"
        |> TsEncode.buildUnion


toElm : Decoder ToElm
toElm =
    TsDecode.discriminatedUnion "tag"
        [ ( "TO_ELM_NOOP"
          , TsDecode.succeed ToElmNoOp
          )
        ]


flagsDecoder : Decoder Flags
flagsDecoder =
    TsDecode.map2 Flags
        (TsDecode.field "screenSize" screenSizeDecoder)
        (TsDecode.field "url" TsDecode.string)


screenSizeDecoder : Decoder ScreenSize
screenSizeDecoder =
    TsDecode.tuple TsDecode.int TsDecode.int
        |> TsDecode.andThen (decodeScreenSize |> TsDecode.andThenInit)


decodeScreenSize : ( Int, Int ) -> Decoder ScreenSize
decodeScreenSize ( innerWidth, innerHeight ) =
    if innerWidth < 1024 then
        TsDecode.succeed <| Mobile innerWidth innerHeight

    else
        TsDecode.succeed <| Desktop innerWidth innerHeight
