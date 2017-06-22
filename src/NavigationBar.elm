module NavigationBar exposing (..)

import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


navigation : Pages -> Html Msg
navigation currentPage =
    nav [ class "navbar navbar-default navbar-fixed-top topnav" ]
        [ div
            [ class "container-fluid topnav" ]
            [ div
                [ class "navbar-header" ]
                [ button
                    [ class "navbar-toggle" ]
                    [ span
                        [ class "sr-only" ]
                        [ text "Toggle navigation" ]
                    , span
                        [ class "icon-bar" ]
                        []
                    , span
                        [ class "icon-bar" ]
                        []
                    , span
                        [ class "icon-bar" ]
                        []
                    , span
                        [ class "icon-bar" ]
                        []
                    ]
                , img
                    [ class "img-responsive navbar-minilogo", src "img/loyd.png", alt "" ]
                    []
                , p
                    [ class "legende" ]
                    [ text "Focus by Loyd Consult" ]
                ]
            , div
                [ class "collapse navbar-collapse", id "bs-example-navbar-collapse-1" ]
                [ ul
                    [ class "nav navbar-nav navbar-right" ]
                    [ li
                        []
                        [ a
                            [ href "#", onClick GoToHomePage ]
                            [ text "Home" ]
                        ]
                    , li
                        []
                        [ a
                            [ href "#", onClick GoToThreatForm ]
                            [ text "New threat" ]
                        ]
                    , li
                        []
                        [ a
                            [ href "#", onClick GoToOpportunityForm ]
                            [ text "New opportunity" ]
                        ]
                    , li
                        []
                        [ a
                            [ href "#", onClick GoToDashboardPage ]
                            [ text "Dashboard" ]
                        ]
                    , li
                        []
                        [ a
                            [ href "#", onClick GoToLoginPage ]
                            [ text "Log Out" ]
                        ]
                    ]
                ]
            ]
        ]
