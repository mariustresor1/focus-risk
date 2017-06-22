module ConfirmationPage exposing (..)

import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


confirmationPage : Html Msg
confirmationPage =
    div
        [ class "block" ]
        [ div
            [ class "container container--thankyou" ]
            [ h1
                []
                [ text "📌 Thank you!" ]
            , p
                [ class "lead" ]
                [ text "We confirm that your input has been recorded. We will inform you of the follow-up given soon." ]
            , p
                [ class "lead" ]
                [ text "For any request or query about the process, you can contact your dedicated risk manager: "
                , a
                    [ href "mailto:contact@risk-focus.com" ]
                    [ text "contact@risk-focus.com" ]
                , text
                    "."
                ]
            ]
        , div
            [ class "container container-confirmation-btn" ]
            [ div
                [ class "row " ]
                [ div
                    [ class "col-md-6 col--button--space" ]
                    [ a
                        [ href "#"
                        , class "btn blue-circle-button"
                        , onClick GoToThreatForm
                        ]
                        [ text "Submit another risk" ]
                    ]
                , div
                    [ class "col-md-6 " ]
                    [ a
                        [ href "#"
                        , class "btn white-circle-button"
                        , onClick GoToDashboardPage
                        ]
                        [ text "View your dashboard" ]
                    ]
                ]
            ]
        ]
