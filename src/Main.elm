port module Main exposing (Msg(..), main, update, view)

import Browser
import Browser.Events
import Dict exposing (Dict)
import Element exposing (..)
import Element.Input as Input
import Html exposing (Html)
import Html.Events
import Json.Decode as D
import Json.Encode as E
import Random
import String exposing (isEmpty)
import Task
import Time exposing (Month(..), Zone)
import UI
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
    , device : Device
    }


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions =
            \_ ->
                Browser.Events.onResize (\w h -> WindowResized w h)
        }


fetchCurrentZone : Cmd Msg
fetchCurrentZone =
    Time.here |> Task.perform GotZone


type alias Flags =
    { initialRawState : Maybe String
    , windowHeight : Int
    , windowWidth : Int
    }


init : Flags -> ( Model, Cmd Msg )
init { initialRawState, windowHeight, windowWidth } =
    let
        device =
            classifyDevice { height = windowHeight, width = windowWidth }

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
            initialRawState
                |> Maybe.map decodeEntries
                |> Maybe.withDefault []
      , currentText = ""
      , zone = Nothing
      , device = device
      }
    , fetchCurrentZone
    )


type Msg
    = UpdateCurrentText String
    | ResetEntries
    | GotZone Zone
    | DuplicateEntry Entry
    | QuickAddItem String
    | WindowResized Int Int
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
        WindowResized w h ->
            ( { model | device = classifyDevice { width = w, height = h } }, Cmd.none )

        GotZone zone ->
            ( { model | zone = Just zone }, Cmd.none )

        UpdateCurrentText newText ->
            ( { model | currentText = newText }, Cmd.none )

        TriggerAddEntry ->
            if isEmpty model.currentText then
                ( model, Cmd.none )

            else
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

        QuickAddItem name ->
            ( model, newEntry name )

        ResetEntries ->
            ( { model | entries = [] }, saveEntries [] )


view : Model -> Html Msg
view model =
    Element.layout [] <|
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
                , UI.button []
                    { onPress = Just TriggerAddEntry
                    , label = text "Add entry"
                    }
                ]
    in
    column
        [ width fill
        , spacing 20
        ]
        [ UI.button
            []
            { onPress = Just ResetEntries
            , label = text "Reset entries"
            }
        , viewQuickAddEntries model
        , inputForm
        , entriesList model
        ]


countItems : List Entry -> Dict String Int
countItems entries =
    let
        countFn : Entry -> Dict String Int -> Dict String Int
        countFn new acc =
            case Dict.get new.content acc of
                Just e ->
                    Dict.insert new.content (e + 1) acc

                Nothing ->
                    Dict.insert new.content 1 acc
    in
    List.foldl countFn Dict.empty entries


createQuickAddItems : Model -> List (Element Msg)
createQuickAddItems model =
    let
        filterFn _ count =
            count > 4
    in
    countItems model.entries
        |> Dict.filter filterFn
        |> Dict.toList
        |> List.sortBy (\( _, v ) -> v)
        |> List.reverse
        |> List.map (\( i, count ) -> createQuickAddItem i count)


createQuickAddItem : String -> Int -> Element Msg
createQuickAddItem name count =
    UI.button []
        { onPress = Just (QuickAddItem name)
        , label = text (name ++ " (" ++ String.fromInt count ++ ")")
        }


viewQuickAddEntries : Model -> Element Msg
viewQuickAddEntries model =
    let
        quickAddItems =
            createQuickAddItems model
    in
    if List.isEmpty quickAddItems then
        Element.none

    else
        column [ spacingXY 0 15 ]
            [ Element.el [] (text "Quick add")
            , wrappedRow [ spacing 10 ] quickAddItems
            ]


sortEntries : List Entry -> List Entry
sortEntries entries =
    let
        extractTimeInt e =
            e.created
                |> Time.posixToMillis
    in
    List.sortBy extractTimeInt entries
        |> List.reverse


entriesList : Model -> Element Msg
entriesList model =
    let
        zone =
            Maybe.withDefault Time.utc model.zone
    in
    column [ width fill ] <|
        viewEntries (sortEntries model.entries) zone


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
        , UI.button
            []
            { onPress = Just (DuplicateEntry entry)
            , label = text "Duplicate"
            }
        ]
