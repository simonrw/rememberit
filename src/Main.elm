port module Main exposing (Msg(..), main, update, view)

import Browser
import Element exposing (..)
import Element.Input as Input
import Html exposing (Html)
import Html.Events
import Json.Decode as D
import Json.Encode as E
import Random
import Task
import Time exposing (Month(..), Zone)
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
        , ( "created", E.int <| Time.posixToMillis entry.created // 1000 )
        ]


getTimeForEntry : String -> UUID -> Cmd Msg
getTimeForEntry s id =
    Time.now
        |> Task.perform (AppendEntry s id)



-- new model flow
-- -> button triggers new model request (AddEntry)
-- -> new model request triggers uuid generation (GenerateEntryId)
-- -> new model added to the state (AppendEntry)


newEntry : String -> Cmd Msg
newEntry s =
    Random.generate (GetTimeForEntry s) UUID.generator


type alias Entry =
    { id : UUID
    , content : String
    , created : Time.Posix
    }


type alias Model =
    { entries : List Entry
    , currentText : String
    , zone : Maybe Zone
    }


main : Program (Maybe String) Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


fetchCurrentZone : Cmd Msg
fetchCurrentZone =
    Time.here |> Task.perform GotZone


init : Maybe String -> ( Model, Cmd Msg )
init maybeEntries =
    let
        entryDecoder : D.Decoder Entry
        entryDecoder =
            D.map3 Entry
                (D.at [ "id" ] UUID.jsonDecoder)
                (D.at [ "content" ] D.string)
                (D.at [ "created" ] <| D.map (\t -> Time.millisToPosix (t * 1000)) D.int)

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
      , zone = Nothing
      }
    , fetchCurrentZone
    )


type Msg
    = UpdateCurrentText String
    | ResetEntries
    | GotZone Zone
    | DuplicateEntry Entry
      -- new entry flow
    | TriggerAddEntry
    | GetTimeForEntry String UUID
    | AppendEntry String UUID Time.Posix


printMonth : Month -> String
printMonth month =
    case month of
        Jan ->
            "01"

        Feb ->
            "02"

        Mar ->
            "03"

        Apr ->
            "04"

        May ->
            "05"

        Jun ->
            "06"

        Jul ->
            "07"

        Aug ->
            "08"

        Sep ->
            "09"

        Oct ->
            "10"

        Nov ->
            "11"

        Dec ->
            "12"


toUtcString : Time.Posix -> Zone -> String
toUtcString time zone =
    String.fromInt (Time.toYear zone time)
        ++ "/"
        ++ (Time.toMonth zone time |> printMonth)
        ++ "/"
        ++ String.fromInt (Time.toDay zone time)
        ++ " "
        ++ String.fromInt (Time.toHour zone time)
        ++ ":"
        ++ String.fromInt (Time.toMinute zone time)
        ++ ":"
        ++ String.fromInt (Time.toSecond zone time)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotZone zone ->
            ( { model | zone = Just zone }, Cmd.none )

        UpdateCurrentText newText ->
            ( { model | currentText = newText }, Cmd.none )

        TriggerAddEntry ->
            ( { model | currentText = "" }, newEntry model.currentText )

        GetTimeForEntry n id ->
            ( model, getTimeForEntry n id )

        AppendEntry s id t ->
            let
                entry =
                    { id = id
                    , content = s
                    , created = t
                    }

                newEntries =
                    model.entries ++ [ entry ]
            in
            ( { model | entries = newEntries }, saveEntries newEntries )

        DuplicateEntry entry ->
            ( model, newEntry entry.content )

        ResetEntries ->
            ( { model | entries = [] }, saveEntries [] )


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
            { onPress = Just ResetEntries
            , label = text "Reset entries"
            }
        , inputForm
        , entriesList model
        ]


entriesList : Model -> Element Msg
entriesList model =
    let
        zone =
            Maybe.withDefault Time.utc model.zone
    in
    column [ width fill ] <|
        viewEntries model.entries zone


viewEntries : List Entry -> Zone -> List (Element Msg)
viewEntries entries zone =
    List.map (viewEntry zone) entries


viewEntry : Zone -> Entry -> Element Msg
viewEntry zone entry =
    let
        s =
            toUtcString entry.created zone ++ ": " ++ entry.content
    in
    row
        [ spacingXY 50 0
        , width fill
        ]
        [ el [ width fill ] (text s)
        , Input.button
            []
            { onPress = Just (DuplicateEntry entry)
            , label = text "Duplicate"
            }
        ]
