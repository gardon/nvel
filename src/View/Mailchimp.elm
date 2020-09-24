module View.Mailchimp exposing (mailchimpBlock)

import Html exposing (div, Html, label, input, text, span)
import Html.Attributes exposing (id, class, action, method, name, target, attribute, value, placeholder, style, type_, tabindex)
import Language exposing (translate)
import Models exposing (Model, Phrase(..))
import Skeleton exposing (skeletonGridSize, GridSize(..))


mailchimpBlock : Model -> Html msg
mailchimpBlock model =
    let
        mailchimp_action =
            "//abismos.us12.list-manage.com/subscribe/post?u=3d03ee122031fb9d8b086b942&amp;id=35a44ac040"

        text_message =
            translate model.language MailchimpText

        small_message =
            translate model.language MailchimpSmall

        button_text =
            translate model.language MailchimpButton
    in
    div (skeletonGridSize TwelveColumns)
        [ div [ id "mc_embed_signup" ]
            [ label [ Html.Attributes.for "mce-EMAIL" ] [ text text_message ]
            , Html.form
                [ action mailchimp_action
                , method "post"
                , id "mc-embedded-subscribe-form"
                , name "mc-embedded-subscribe-form"
                , class "validate"
                , target "_blank"
                , attribute "novalidate" ""
                , attribute "_lpchecked" "1"
                ]
                [ div [ id "mc_embed_signup_scroll" ]
                    [ input
                        [ value ""
                        , name "EMAIL"
                        , class "email"
                        , id "mce-EMAIL"
                        , placeholder "E-mail"
                        , attribute "required" ""
                        , type_ "email"
                        , attribute "aria-describedby" "mailchimp-small"
                        ]
                        []
                    , div [ style "position" "absolute", style "left" "-5000px", attribute "aria-hidden" "true" ]
                        [ input [ name "b_3d03ee122031fb9d8b086b942_35a44ac040", tabindex -1, value "", type_ "text" ] []
                        ]
                    , input [ value button_text, name "subscribe", id "mc-embedded-subscribe", class "button button-primary", type_ "submit" ] []
                    ]
                ]
            , span [ id "mailchimp-small" ] [ text small_message ]
            ]
        ]
