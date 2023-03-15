module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
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
    , isPaused : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Time.utc (Time.millisToPosix 0) False
    , Task.perform AdjustTimeZone Time.here
    )


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | Pause


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

        Pause ->
            ( { model | isPaused = not model.isPaused }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.isPaused then
        Sub.none

    else
        Time.every 1000 Tick


view : Model -> Html Msg
view model =
    let
        hour =
            String.fromInt (Time.toHour model.zone model.time * 30)

        minute =
            String.fromInt (Time.toMinute model.zone model.time * 6)

        second =
            String.fromInt (Time.toSecond model.zone model.time * 6)
    in
    div []
        [ Svg.svg
            [ width "500"
            , height "500"
            , viewBox "0 0 500 500"
            ]
            [ Svg.circle [ cx "250", cy "250", r "200", strokeWidth "10", stroke "black", fill "white" ] []
            , Svg.line
                [ x1 "250"
                , y1 "250"
                , x2 "250"
                , y2 "160"
                , stroke "black"
                , strokeWidth "16"
                , strokeLinecap "round"
                , style <| "transform-origin: center; transform: rotate(" ++ hour ++ "deg)"
                ]
                []
            , Svg.line
                [ x1 "250"
                , y1 "250"
                , x2 "250"
                , y2 "120"
                , stroke "black"
                , strokeWidth "10"
                , strokeLinecap "round"
                , style <| "transform-origin: center; transform: rotate(" ++ minute ++ "deg)"
                ]
                []
            , Svg.line
                [ x1 "250"
                , y1 "250"
                , x2 "250"
                , y2 "80"
                , stroke "red"
                , strokeWidth "4"
                , strokeLinecap "round"
                , style <| "transform-origin: center; transform: rotate(" ++ second ++ "deg)"
                ]
                []
              , Svg.circle [ cx "250", cy "250", r "4" ] []
            ]
        , button [ onClick Pause ]
            [ text (if model.isPaused then "Play" else "Pause") ]
        ]
