module HomePage exposing (..)

import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- View


homePage : Html Msg
homePage =
    div
        [ class "block block--home" ]
        [ div
            [ class "container" ]
            [ div
                [ class "row" ]
                [ h1
                    []
                    [ text "Welcome to your Risk Management tool" ]
                , p
                    []
                    [ text "The aim of Risk Focus is to identify and qualify all the uncertainties (opportunities or threats) that could affect our organization. All these uncertainties have to be analysed in relation with their potential impact on the achievement of the Company’s objectives" ]
                , p
                    []
                    [ text "You can find a more thorough description of the Risk Management practices and standards by following the links below:" ]
                , ul
                    []
                    [ li
                        []
                        [ a
                            [ href "https://www.iso.org/iso-31000-risk-management.html", target "_blank" ]
                            [ text "Link to ISO 31000" ]
                        ]
                    , li
                        []
                        [ a
                            [ href "https://www.coso.org/Pages/erm-integratedframework.aspx", target "_blank" ]
                            [ text "Links to COSO Standards" ]
                        ]
                    , li
                        []
                        [ a
                            [ href "" ]
                            [ text "Links to the company rules" ]
                        ]
                    ]
                ]
            , div
                [ class "row container--objectives" ]
                [ h3
                    []
                    [ text "Our primary objectives" ]
                , ul
                    []
                    [ li
                        []
                        [ text "Finish on time" ]
                    , li
                        []
                        [ text "Within costs" ]
                    , li
                        []
                        [ text "High quality" ]
                    , li
                        []
                        [ text "Respect HSE guidelines" ]
                    ]
                ]
            ]
        , div
            [ class "container container--team" ]
            [ div
                [ class "row" ]
                [ h3
                    []
                    [ text "Your contacts" ]
                , div
                    [ class "row row--team" ]
                    [ div
                        [ class "team-img" ]
                        [ img
                            [ class "img-responsive img-team", src "img/guillaume.png", alt "" ]
                            []
                        ]
                    , div
                        [ class "team-description" ]
                        [ h4
                            []
                            [ text "Marianne Scheiman" ]
                        , p
                            []
                            [ text "Risk Manager" ]
                        , a
                            [ href "mailto:guillaume.niarfeix@loydconsult.com" ]
                            [ text "marianne.scheiman@gasco.com" ]
                        ]
                    ]
                , div
                    [ class "row row--team" ]
                    [ div
                        [ class "team-img" ]
                        [ img
                            [ class "img-responsive img-team", src "img/alasdair.png", alt "" ]
                            []
                        ]
                    , div
                        [ class "team-description" ]
                        [ h4
                            []
                            [ text "Andrew Ferguson" ]
                        , p
                            []
                            [ text "Head of methods" ]
                        , a
                            [ href "mailto:alasdair.philip@loydconsult.com" ]
                            [ text "andrew.ferguson@gasco.com" ]
                        ]
                    ]
                ]
            ]
        , div
            [ class "container container--home-declare-btn" ]
            [ div
                [ class "row" ]
                [ div
                    [ class "col-md-6" ]
                    [ a
                        [ href "#"
                        , class "btn blue-circle-button"
                        , onClick GoToThreatForm
                        ]
                        [ text "Identify a Threat" ]
                    ]
                , div
                    [ class "col-md-6" ]
                    [ a
                        [ href "#"
                        , class "btn blue-circle-button"
                        , onClick GoToOpportunityForm
                        ]
                        [ text "Identify an Opportunity" ]
                    ]
                ]
            ]
        ]
