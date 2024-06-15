module Main exposing (Msg(..), main, update, view)

import Browser
import Html exposing (Html, button, div, h1, input, label, p, text)
import Html.Attributes exposing (style, value)
import Html.Events exposing (onClick, onInput)


type alias Entry =
    { id : String
    , content : String
    , created : String
    }


type alias Model =
    { entries : List Entry
    , currentText : String
    }


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }


init : Model
init =
    -- TODO: get from localstorage
    { entries = []
    , currentText = ""
    }


type Msg
    = UpdateCurrentText String
    | AddEntry


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateCurrentText newText ->
            { model | currentText = newText }

        AddEntry ->
            let
                newEntry =
                    { id = ""
                    , content = model.currentText
                    , created = ""
                    }
            in
            { model | entries = model.entries ++ [ newEntry ], currentText = "" }


view : Model -> Html Msg
view model =
    div [ style "padding" "1em" ]
        [ h1 [] [ text "RememberIt" ]
        , div []
            [ button [] [ text "Reset entries" ]
            ]
        , div []
            [ label [] [ text "Entry" ]
            , input [ onInput UpdateCurrentText, value model.currentText ] []
            , button [ onClick AddEntry ] [ text "Add entry" ]
            ]
        , div []
            (viewEntries model.entries)
        ]


viewEntries : List Entry -> List (Html Msg)
viewEntries entries =
    List.map viewEntry entries


viewEntry : Entry -> Html Msg
viewEntry entry =
    let
        s =
            entry.created ++ " " ++ entry.content
    in
    p [] [ text s ]
