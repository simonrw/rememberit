port module Main exposing (Msg(..), main, update, view)

import Browser
import Browser.Events
import Dict exposing (Dict)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events
import Json.Decode as D
import Json.Encode as E
import Random
import String exposing (isEmpty)
import Task
import Time exposing (Month(..), Zone, ZoneName(..))
import UI
import UUID exposing (UUID)



-- sizing


scaled : Int -> Int
scaled rescale =
    Element.modular 16 1.25 rescale
        |> round



-- ports


port saveToClipboard : () -> Cmd msg


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
        , ( "created", E.int <| Time.posixToMillis entry.created )
        ]


getTimeForEntry : String -> UUID -> Cmd Msg
getTimeForEntry s id =
    Time.now
        |> Task.perform (AppendEntry s id)



-- time conversion


port convertTime : String -> Cmd msg


port timeConversionResult : (Int -> msg) -> Sub msg


sendTimeForConversion : ZoneName -> String -> Cmd msg
sendTimeForConversion zoneName datestr =
    case zoneName of
        Name name ->
            E.object
                [ ( "text", E.string datestr )
                , ( "zoneName", E.string name )
                ]
                |> E.encode 0
                |> convertTime

        Offset _ ->
            Cmd.none



-- new model flow
-- -> button triggers new model request (AddEntry)
-- -> new model request triggers uuid generation (GenerateEntryId)
-- -> new model added to the state (AppendEntry)


createNewEntry : String -> Cmd Msg
createNewEntry s =
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
    , zoneName : Maybe ZoneName
    , device : Device
    , editingEntry : Maybe Entry
    , importPanelOpen : Bool
    , importContent : String
    }


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions =
            \_ ->
                Sub.batch
                    [ Browser.Events.onResize (\w h -> WindowResized w h)
                    , timeConversionResult TimeConversionResultReceived
                    ]
        }


fetchCurrentZone : Cmd Msg
fetchCurrentZone =
    Time.here |> Task.perform GotZone


fetchCurrentZoneName : Cmd Msg
fetchCurrentZoneName =
    Time.getZoneName |> Task.perform GotZoneName


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
                (D.at [ "created" ] <| D.map (\t -> Time.millisToPosix t) D.int)

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
      , zoneName = Nothing
      , device = device
      , editingEntry = Nothing
      , importPanelOpen = False
      , importContent = ""
      }
    , Cmd.batch
        [ fetchCurrentZone
        , fetchCurrentZoneName
        ]
    )


type Msg
    = UpdateCurrentText String
    | ResetEntries
    | GotZone Zone
    | GotZoneName ZoneName
    | DuplicateEntry Entry
    | QuickAddItem String
    | WindowResized Int Int
    | TriggerUpdateEntry Entry
    | FinishedEditing
    | UpdateEditingEntry String
    | UpdateEditingTime String
    | TimeConversionResultReceived Int
    | SaveToClipboard
    | ToggleImportPanel
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


padWithLeadingZeroes : String -> String
padWithLeadingZeroes =
    String.pad 2 '0'


datetimePickerDatetime : Zone -> Time.Posix -> String
datetimePickerDatetime zone time =
    String.fromInt (Time.toYear zone time)
        ++ "-"
        ++ (Time.toMonth zone time |> printMonth)
        ++ "-"
        ++ (String.fromInt (Time.toDay zone time) |> padWithLeadingZeroes)
        ++ "T"
        ++ (String.fromInt (Time.toHour zone time) |> padWithLeadingZeroes)
        ++ ":"
        ++ (String.fromInt (Time.toMinute zone time) |> padWithLeadingZeroes)


toUtcString : Zone -> Time.Posix -> String
toUtcString zone time =
    datetimePickerDatetime zone time
        ++ ":"
        ++ (String.fromInt (Time.toSecond zone time) |> padWithLeadingZeroes)


datePicker : Time.Zone -> Time.Posix -> Element Msg
datePicker zone time =
    Html.input
        [ Attrs.type_ "datetime-local"
        , Attrs.value <| datetimePickerDatetime zone time
        , Html.Events.onInput UpdateEditingTime
        ]
        []
        |> Element.html


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WindowResized w h ->
            ( { model | device = classifyDevice { width = w, height = h } }, Cmd.none )

        GotZone zone ->
            ( { model | zone = Just zone }, Cmd.none )

        GotZoneName zoneName ->
            ( { model | zoneName = Just zoneName }, Cmd.none )

        UpdateCurrentText newText ->
            ( { model | currentText = newText }, Cmd.none )

        TriggerAddEntry ->
            if isEmpty model.currentText then
                ( model, Cmd.none )

            else
                ( { model | currentText = "" }, createNewEntry model.currentText )

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
            ( model, createNewEntry entry.content )

        QuickAddItem name ->
            ( model, createNewEntry name )

        ResetEntries ->
            ( { model | entries = [] }, saveEntries [] )

        TriggerUpdateEntry original ->
            ( { model | editingEntry = Just original }, Cmd.none )

        FinishedEditing ->
            case model.editingEntry of
                Just e ->
                    let
                        nonEditedEntries =
                            List.filter (\entry -> entry.id /= e.id) model.entries

                        newEntriesList =
                            nonEditedEntries ++ [ e ]
                    in
                    ( { model | editingEntry = Nothing, entries = newEntriesList }, saveEntries newEntriesList )

                Nothing ->
                    -- TODO: programming error
                    ( model, Cmd.none )

        UpdateEditingEntry text ->
            case model.editingEntry of
                Just e ->
                    let
                        new =
                            { e | content = text }
                    in
                    ( { model | editingEntry = Just new }, Cmd.none )

                Nothing ->
                    -- TODO: programming error
                    ( model, Cmd.none )

        UpdateEditingTime text ->
            case model.zoneName of
                Just zoneName ->
                    ( model, sendTimeForConversion zoneName text )

                Nothing ->
                    -- TODO :programming error
                    ( model, Cmd.none )

        TimeConversionResultReceived millis ->
            case model.editingEntry of
                Just current ->
                    let
                        newEntry =
                            { current | created = Time.millisToPosix millis }
                    in
                    ( { model | editingEntry = Just newEntry }, Cmd.none )

                Nothing ->
                    -- TODO: programming error
                    ( model, Cmd.none )

        SaveToClipboard ->
            ( model, saveToClipboard () )

        ToggleImportPanel ->
            ( { model | importPanelOpen = True }, Cmd.none )


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
    el [ Font.size (scaled 4) ] (text "RememberIt")


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
            row [ width fill, spacing 16 ]
                [ Input.text
                    [ width fill
                    , Input.focusedOnLoad
                    , onEnter TriggerAddEntry
                    , spacing 16
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
        [ row [ spacingXY 20 0 ]
            [ UI.button
                []
                { onPress = Just ResetEntries
                , label = text "Reset entries"
                }
            , UI.button
                []
                { onPress = Just SaveToClipboard
                , label = text "Export entries"
                }
            , UI.button
                []
                { onPress = Just ToggleImportPanel
                , label = text "Import entries"
                }
            ]
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
            count >= 2
    in
    countItems model.entries
        |> Dict.filter filterFn
        |> Dict.toList
        |> List.sortBy (\( _, v ) -> v)
        |> List.reverse
        |> List.take 5
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
    column [ width fill, spacingXY 0 16 ] <|
        viewEntries model.device (sortEntries model.entries) zone model.editingEntry


viewEntries : Device -> List Entry -> Zone -> Maybe Entry -> List (Element Msg)
viewEntries device entries zone editingEntry =
    List.map (viewEntry device zone editingEntry) entries


viewEntry : Device -> Zone -> Maybe Entry -> Entry -> Element Msg
viewEntry device zone editingEntry entry =
    let
        s =
            toUtcString zone entry.created ++ ": " ++ entry.content

        editing =
            case editingEntry of
                Just e ->
                    e.id == entry.id

                Nothing ->
                    False

        entryContent =
            if editing then
                editingContent

            else
                normalContent

        editingContent =
            [ datePicker
                zone
                (editingEntry
                    |> Maybe.map (\e -> e.created)
                    |> Maybe.withDefault (Time.millisToPosix 0)
                )
            , Input.text
                [ width fill
                ]
                { onChange = UpdateEditingEntry
                , text =
                    editingEntry
                        |> Maybe.map (\e -> e.content)
                        |> Maybe.withDefault ""
                , placeholder = Nothing
                , label = Input.labelLeft [] (text "Entry")
                }
            , UI.button
                []
                { onPress = Just FinishedEditing
                , label = text "Done"
                }
            ]

        normalContent =
            let
                phoneLayout =
                    [ column
                        [ width fill
                        , padding 16
                        , spacingXY 0 8
                        ]
                        [ el [ width fill ] (text s)
                        , row
                            [ width fill
                            , centerX
                            , spacingXY 16 0
                            ]
                            [ UI.button
                                []
                                { onPress = Just (DuplicateEntry entry)
                                , label = text "Duplicate"
                                }
                            , UI.button
                                []
                                { onPress = Just (TriggerUpdateEntry entry)
                                , label = text "Update"
                                }
                            ]
                        ]
                    ]

                desktopLayout =
                    [ el [ width fill ] (text s)
                    , UI.button
                        []
                        { onPress = Just (DuplicateEntry entry)
                        , label = text "Duplicate"
                        }
                    , UI.button
                        []
                        { onPress = Just (TriggerUpdateEntry entry)
                        , label = text "Update"
                        }
                    ]
            in
            case device.class of
                Phone ->
                    phoneLayout

                Tablet ->
                    phoneLayout

                _ ->
                    desktopLayout

        backgroundColor =
            case device.class of
                Phone ->
                    rgba255 0x42 0x99 0xE1 0.1

                Tablet ->
                    rgba255 0x42 0x99 0xE1 0.1

                _ ->
                    rgba255 0 0 0 0.0
    in
    row
        [ spacingXY 50 8
        , width fill
        , Background.color backgroundColor
        , Border.rounded 15
        , padding 8
        ]
        entryContent
