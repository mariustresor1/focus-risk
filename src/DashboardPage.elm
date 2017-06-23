module DashboardPage exposing (dashboardPage)

import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Time.TimeZones exposing (europe_paris)
import Time.DateTime as DateTime exposing (DateTime)
import Time.ZonedDateTime as ZonedDateTime exposing (ZonedDateTime)


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
            DateTime.fromTimestamp <| toFloat risk.last_modified
    in
        tr []
            [ td [] [ text <| formatID risk.id ]
            , td [] [ text <| showDate date ]
            , td [] [ text risk.title ]
            , td [] [ text risk.admin.comment ]
            , td [] <| badge risk.admin.status
            ]


badge : String -> List (Html Msg)
badge status =
    case status of
        "Closed" ->
            [ i [ class "fa fa-check-circle", style [ ( "color", "green" ) ] ] []
            , text " "
            , text status
            ]

        "Rejected" ->
            [ i [ class "fa fa-times-circle", style [ ( "color", "red" ) ] ] []
            , text " "
            , text status
            ]

        _ ->
            [ text status ]


formatID : String -> String
formatID id =
    "RT-" ++ String.slice 0 3 id ++ "-" ++ String.slice 3 5 id


showDate : DateTime -> String
showDate datetime =
    let
        zoned =
            ZonedDateTime.fromDateTime (europe_paris ()) datetime

        day =
            ZonedDateTime.day zoned

        month =
            ZonedDateTime.month zoned

        year =
            ZonedDateTime.year zoned

        hour =
            ZonedDateTime.hour zoned

        minute =
            ZonedDateTime.minute zoned
    in
        (zfill day) ++ "/" ++ (zfill month) ++ "/" ++ (toString year) ++ " " ++ (zfill hour) ++ ":" ++ (zfill minute)


zfill : Int -> String
zfill value =
    let
        string =
            toString value
    in
        if (String.length string) == 1 then
            "0" ++ string
        else
            string
