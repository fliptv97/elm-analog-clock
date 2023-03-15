module Main exposing (..)

import Browser
import Html exposing (..)
import Svg
import Svg.Attributes exposing (..)
import Task
import Time


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Time.utc (Time.millisToPosix 0)
    , Task.perform AdjustTimeZone Time.here
    )


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 Tick


view : Model -> Html Msg
view model =
    let
        hour =
            Time.toHour model.zone model.time * 30

        minute =
            Time.toMinute model.zone model.time * 6

        second =
            Time.toSecond model.zone model.time * 6
    in
    div []
        [ Svg.svg
            [ width "500"
            , height "500"
            , viewBox "0 0 500 500"
            ]
            [ Svg.circle [ cx "250", cy "250", r "200", strokeWidth "10", stroke "black", fill "white" ] []
            , arrow { rotationAngle = hour, width = 12, length = 80, color = "black" }
            , arrow { rotationAngle = minute, width = 8, length = 130, color = "black" }
            , arrow { rotationAngle = second, width = 4, length = 170, color = "red" }
            , Svg.circle [ cx "250", cy "250", r "4" ] []
            ]
        ]


type alias ArrowParams =
    { rotationAngle : Int
    , width : Int
    , length : Int
    , color : String
    }


arrow : ArrowParams -> Svg.Svg Msg
arrow params =
    Svg.line
        [ x1 "250"
        , y1 "250"
        , x2 "250"
        , y2 (String.fromInt (250 - params.length))
        , stroke params.color
        , strokeWidth (String.fromInt params.width)
        , strokeLinecap "round"
        , style <| "transform-origin: center; transform: rotate(" ++ String.fromInt params.rotationAngle ++ "deg)"
        ]
        []
