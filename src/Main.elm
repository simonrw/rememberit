module Main exposing (Msg(..), main, update, view)

import Browser
import Html exposing (button, div, h1, input, label, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)


main : Program () Int Msg
main =
    Browser.sandbox { init = 0, update = update, view = view }


type Msg
    = Increment
    | Decrement


update : Msg -> number -> number
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1


view : Int -> Html.Html Msg
view _ =
    div [ style "padding" "1em" ]
        [ h1 [] [ text "RememberIt" ]
        , div []
            [ button [] [ text "Reset entries" ]
            ]
        , div []
            [ label [] [ text "Entry" ]
            , input [] []
            , button [] [ text "Add entry" ]
            ]
        ]
