module Main exposing (Msg(..), main, update, view)

import Browser
import Html exposing (Html, button, div, h1, input, label, p, text)
import Html.Attributes exposing (style, value)
import Html.Events exposing (onClick, onInput)
import Random
import UUID exposing (UUID)



-- new model flow
-- -> button triggers new model request (AddEntry)
-- -> new model request triggers uuid generation (GenerateEntryId)
-- -> new model added to the state (AppendEntry)


newEntry : NewEntry -> Cmd Msg
newEntry n =
    Random.generate (AppendEntry n) UUID.generator


type alias Entry =
    { id : UUID
    , content : String
    , created : String
    }


type alias NewEntry =
    { content : String
    , created : String
    }


type alias Model =
    { entries : List Entry
    , currentText : String
    }


main : Program () Model Msg
main =
    Browser.element { init = init, update = update, view = view, subscriptions = \_ -> Sub.none }


init : () -> ( Model, Cmd Msg )
init _ =
    -- TODO: get from localstorage
    ( { entries = []
      , currentText = ""
      }
    , Cmd.none
    )


type Msg
    = UpdateCurrentText String
      -- new entry flow
    | TriggerAddEntry
    | AppendEntry NewEntry UUID



-- | NewUUID UUID


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateCurrentText newText ->
            ( { model | currentText = newText }, Cmd.none )

        TriggerAddEntry ->
            let
                n =
                    { content = model.currentText
                    , created = ""
                    }
            in
            ( model, newEntry n )

        AppendEntry n id ->
            let
                entry =
                    { id = id
                    , content = n.content
                    , created = n.created
                    }
            in
            ( { model | entries = model.entries ++ [ entry ] }, Cmd.none )


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
            , button [ onClick TriggerAddEntry ] [ text "Add entry" ]
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
