port module Main exposing (Msg(..), main, update, view)

import Browser
import Element exposing (..)
import Element.Input as Input
import Html exposing (Html)
import Html.Events
import Json.Decode as D
import Json.Encode as E
import Random
import UUID exposing (UUID)



-- ports


port storeEntries : String -> Cmd msg


saveEntries : List Entry -> Cmd msg
saveEntries entries =
    E.list entryEncoder entries
        |> E.encode 0
        |> storeEntries


entryEncoder : Entry -> E.Value
entryEncoder entry =
    E.object
        [ ( "id", E.string (UUID.toString entry.id) )
        , ( "content", E.string entry.content )
        , ( "created", E.string entry.created )
        ]



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


main : Program (Maybe String) Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


init : Maybe String -> ( Model, Cmd Msg )
init maybeEntries =
    let
        entryDecoder : D.Decoder Entry
        entryDecoder =
            D.map3 Entry
                (D.at [ "id" ] UUID.jsonDecoder)
                (D.at [ "content" ] D.string)
                (D.at [ "created" ] D.string)

        entriesDecoder : D.Decoder (List Entry)
        entriesDecoder =
            D.list entryDecoder

        decodeEntries text =
            case D.decodeString entriesDecoder text of
                Ok entries ->
                    entries

                Err _ ->
                    []
    in
    ( { entries =
            maybeEntries
                |> Maybe.map decodeEntries
                |> Maybe.withDefault []
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
            ( { model | currentText = "" }, newEntry n )

        AppendEntry n id ->
            let
                entry =
                    { id = id
                    , content = n.content
                    , created = n.created
                    }

                newEntries =
                    model.entries ++ [ entry ]
            in
            ( { model | entries = newEntries }, saveEntries newEntries )


view : Model -> Html Msg
view model =
    Element.layout [ explain Debug.todo ] <|
        column
            [ width fill
            , padding 20
            , spacing 20
            ]
            [ header
            , content model
            ]


header : Element Msg
header =
    el [] (text "RememberIt")


content : Model -> Element Msg
content model =
    let
        onEnter msg =
            Element.htmlAttribute
                (Html.Events.on "keyup"
                    (D.field "key" D.string
                        |> D.andThen
                            (\key ->
                                if key == "Enter" then
                                    D.succeed msg

                                else
                                    D.fail "Not the enter key"
                            )
                    )
                )
    in
    let
        inputForm =
            row [ width fill ]
                [ Input.text
                    [ width fill
                    , Input.focusedOnLoad
                    , onEnter TriggerAddEntry
                    ]
                    { onChange = UpdateCurrentText
                    , text = model.currentText
                    , placeholder = Nothing
                    , label = Input.labelLeft [] (text "Entry")
                    }
                , Input.button []
                    { onPress = Just TriggerAddEntry
                    , label = text "Add entry"
                    }
                ]
    in
    column
        [ width fill
        , spacing 20
        ]
        [ Input.button
            []
            { onPress = Nothing
            , label = text "Reset entries"
            }
        , inputForm
        , entriesList model
        ]


entriesList : Model -> Element Msg
entriesList model =
    column [] <| viewEntries model.entries


viewEntries : List Entry -> List (Element Msg)
viewEntries entries =
    List.map viewEntry entries


viewEntry : Entry -> Element Msg
viewEntry entry =
    let
        s =
            entry.created ++ " " ++ entry.content
    in
    el [] (text s)
