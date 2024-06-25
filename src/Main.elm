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


entryDecoder : D.Decoder Entry
entryDecoder =
    D.map3 Entry
        (D.at [ "id" ] UUID.jsonDecoder)
        (D.at [ "content" ] D.string)
        (D.at [ "created" ] <| D.map (\t -> Time.millisToPosix t) D.int)


entriesDecoder : D.Decoder (List Entry)
entriesDecoder =
    D.list entryDecoder


decodeEntries : String -> List Entry
decodeEntries text =
    case D.decodeString entriesDecoder text of
        Ok entries ->
            entries

        Err _ ->
            []



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


type alias ImportState =
    { zone : Zone
    , zoneName : ZoneName
    , device : Device
    }


type Model
    = Init Flags
    | WithTimeZone Flags Zone
    | EntriesList EntriesListState
    | Import ImportState String


type alias EntriesListState =
    { entries : List Entry
    , currentText : String
    , zone : Zone
    , zoneName : ZoneName
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
init flags =
    ( Init flags, fetchCurrentZone )


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
      -- import state
    | ImportTextChanged String
    | ImportContent
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
update msg fullModel =
    let
        initUpdate flags =
            case msg of
                GotZone zone ->
                    ( WithTimeZone flags zone, fetchCurrentZoneName )

                _ ->
                    ( fullModel, Cmd.none )

        withTimeZoneUpdate { initialRawState, windowWidth, windowHeight } zone =
            case msg of
                GotZoneName name ->
                    let
                        device =
                            classifyDevice { height = windowHeight, width = windowWidth }
                    in
                    ( EntriesList
                        { entries =
                            initialRawState
                                |> Maybe.map decodeEntries
                                |> Maybe.withDefault []
                        , currentText = ""
                        , zone = zone
                        , zoneName = name
                        , device = device
                        , editingEntry = Nothing
                        , importPanelOpen = False
                        , importContent = ""
                        }
                    , Cmd.none
                    )

                _ ->
                    ( fullModel, Cmd.none )

        entriesListUpdate : EntriesListState -> ( Model, Cmd Msg )
        entriesListUpdate model =
            case msg of
                WindowResized w h ->
                    ( EntriesList { model | device = classifyDevice { width = w, height = h } }, Cmd.none )

                UpdateCurrentText newText ->
                    ( EntriesList { model | currentText = newText }, Cmd.none )

                TriggerAddEntry ->
                    if isEmpty model.currentText then
                        ( fullModel, Cmd.none )

                    else
                        ( EntriesList { model | currentText = "" }, createNewEntry model.currentText )

                GetTimeForEntry n id ->
                    ( fullModel, getTimeForEntry n id )

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
                    ( EntriesList { model | entries = newEntries }, saveEntries newEntries )

                DuplicateEntry entry ->
                    ( fullModel, createNewEntry entry.content )

                QuickAddItem name ->
                    ( fullModel, createNewEntry name )

                ResetEntries ->
                    ( EntriesList { model | entries = [] }, saveEntries [] )

                TriggerUpdateEntry original ->
                    ( EntriesList { model | editingEntry = Just original }, Cmd.none )

                FinishedEditing ->
                    case model.editingEntry of
                        Just e ->
                            let
                                nonEditedEntries =
                                    List.filter (\entry -> entry.id /= e.id) model.entries

                                newEntriesList =
                                    nonEditedEntries ++ [ e ]
                            in
                            ( EntriesList { model | editingEntry = Nothing, entries = newEntriesList }, saveEntries newEntriesList )

                        Nothing ->
                            -- TODO: programming error
                            ( fullModel, Cmd.none )

                UpdateEditingEntry text ->
                    case model.editingEntry of
                        Just e ->
                            let
                                new =
                                    { e | content = text }
                            in
                            ( EntriesList { model | editingEntry = Just new }, Cmd.none )

                        Nothing ->
                            -- TODO: programming error
                            ( fullModel, Cmd.none )

                UpdateEditingTime text ->
                    ( fullModel, sendTimeForConversion model.zoneName text )

                TimeConversionResultReceived millis ->
                    case model.editingEntry of
                        Just current ->
                            let
                                newEntry =
                                    { current | created = Time.millisToPosix millis }
                            in
                            ( EntriesList { model | editingEntry = Just newEntry }, Cmd.none )

                        Nothing ->
                            -- TODO: programming error
                            ( fullModel, Cmd.none )

                SaveToClipboard ->
                    ( fullModel, saveToClipboard () )

                ToggleImportPanel ->
                    let
                        importState =
                            { zone = model.zone
                            , zoneName = model.zoneName
                            , device = model.device
                            }
                    in
                    ( Import importState "", Cmd.none )

                _ ->
                    ( fullModel, Cmd.none )

        importUpdate : ImportState -> String -> ( Model, Cmd Msg )
        importUpdate s raw =
            case msg of
                ImportTextChanged t ->
                    ( Import s t, Cmd.none )

                ImportContent ->
                    let
                        newEntries =
                            D.decodeString D.string raw
                                |> Result.map decodeEntries
                                |> Result.withDefault []
                    in
                    ( EntriesList
                        { entries = newEntries
                        , currentText = ""
                        , zone = s.zone
                        , zoneName = s.zoneName
                        , device = s.device
                        , editingEntry = Nothing
                        , importPanelOpen = False
                        , importContent = ""
                        }
                    , saveEntries newEntries
                    )

                _ ->
                    ( fullModel, Cmd.none )
    in
    case fullModel of
        Init flags ->
            initUpdate flags

        WithTimeZone flags zone ->
            withTimeZoneUpdate flags zone

        EntriesList state ->
            entriesListUpdate state

        Import state raw ->
            importUpdate state raw


view : Model -> Html Msg
view model =
    Element.layout [] <|
        case model of
            EntriesList state ->
                column
                    [ width fill
                    , padding 20
                    , spacing 20
                    ]
                    [ header
                    , content state
                    ]

            Import _ value ->
                column
                    [ width fill
                    , padding 20
                    , spacing 20
                    ]
                    [ header
                    , importView value
                    ]

            _ ->
                el [] (text "Loading...")


header : Element Msg
header =
    el [ Font.size (scaled 4) ] (text "RememberIt")


importView : String -> Element Msg
importView value =
    column
        [ width fill
        , height fill
        ]
        [ Input.multiline
            [ width fill
            , height fill
            , Input.focusedOnLoad
            ]
            { onChange = ImportTextChanged
            , text = value
            , placeholder = Nothing
            , label = Input.labelAbove [] (text "Import state")
            , spellcheck = False
            }
        , UI.button []
            { onPress = Just ImportContent
            , label = text "Import content"
            }
        ]


content : EntriesListState -> Element Msg
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


createQuickAddItems : EntriesListState -> List (Element Msg)
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


viewQuickAddEntries : EntriesListState -> Element Msg
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


entriesList : EntriesListState -> Element Msg
entriesList model =
    column [ width fill, spacingXY 0 16 ] <|
        viewEntries model.device (sortEntries model.entries) model.zone model.editingEntry


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
