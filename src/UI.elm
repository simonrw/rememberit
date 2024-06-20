module UI exposing (button)

import Element exposing (Element, paddingXY, rgb255)
import Element.Background as Background
import Element.Border exposing (rounded)
import Element.Font as Font
import Element.Input as Input


buttonAttrs : List (Element.Attribute msg)
buttonAttrs =
    [ paddingXY 8 12
    , rounded 24
    , Background.color (rgb255 0x42 0x99 0xE1)
    , Font.color (rgb255 255 255 255)
    ]


button : List (Element.Attribute msg) -> { onPress : Maybe msg, label : Element msg } -> Element msg
button extraAttrs defn =
    let
        defaultAttrs =
            buttonAttrs ++ []

        attrs =
            Debug.log "Button attributes"
                (defaultAttrs
                    ++ extraAttrs
                )
    in
    Input.button attrs defn
