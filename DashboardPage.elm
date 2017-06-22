module DashboardPage exposing (dashboardPage)

import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Date


dashboardPage : List Risk -> Html Msg
dashboardPage risks =
    div []
        [ div [ class "block" ]
            [ div
                [ class "container" ]
                [ h1
                    []
                    [ text "Your personal dashboard" ]
                ]
            ]
        , div [ class "container-fluid container-dashboard-table" ]
            [ div [ class "row" ]
                [ div [ class "col-sm-12" ]
                    [ div [ class "white-box" ]
                        [ div [ class "table-responsive" ]
                            [ table [ class "table" ]
                                [ thead []
                                    [ tr []
                                        [ th [] [ text "#" ]
                                        , th [] [ text "Report date" ]
                                        , th [] [ text "Title" ]
                                        , th [] [ text "Comment" ]
                                        , th [] [ text "Status" ]
                                        ]
                                    ]
                                , tbody [] <| List.map tableRow risks
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


tableRow : Risk -> Html Msg
tableRow risk =
    let
        date =
            Date.fromTime <| toFloat risk.last_modified
    in
        tr []
            [ td [] [ text risk.id ]
            , td [] [ text <| toString date ]
            , td [] [ text risk.title ]
            , td [] [ text risk.admin.comment ]
            , td [] <| badge risk.admin.status
            ]


badge : String -> List (Html Msg)
badge status =
    case status of
        "Closed" ->
            [ i [ class "fa fa-check-circle", style [ ( "color", "green" ) ] ] []
            , text status
            ]

        "Rejected" ->
            [ i [ class "fa fa-times-circle", style [ ( "color", "red" ) ] ] []
            , text status
            ]

        _ ->
            [ text status ]
