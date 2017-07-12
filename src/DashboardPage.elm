module DashboardPage exposing (dashboardPage)

import Dialog
import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Time.TimeZones exposing (europe_paris)
import Time.DateTime as DateTime exposing (DateTime)
import Time.ZonedDateTime as ZonedDateTime exposing (ZonedDateTime)


dashboardPage : List Risk -> Maybe Risk -> Html Msg
dashboardPage risks selectedRisk =
    let
        displayRisk =
            case selectedRisk of
                Nothing ->
                    div [] []

                Just risk ->
                    Dialog.view <| Just (dialogConfig risk)
    in
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
                                            [ th [ class "dashboardtable-colum-id" ] [ text "#" ]
                                            , th [] [ text "Report" ]
                                            , th [] [ text "Title" ]
                                            , th [] [ text "Comment" ]
                                            , th [ class "dashboardtable-colum-status" ] [ text "Status" ]
                                            ]
                                        ]
                                    , tbody [] <| List.map tableRow risks
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            , displayRisk
            ]



-- Table of risks and opportunities


tableRow : Risk -> Html Msg
tableRow risk =
    let
        date =
            DateTime.fromTimestamp <| toFloat risk.last_modified
    in
        tr []
            [ td [ class "dashboard-modal-title" ] [ a [ href "#risk", onClick (SelectRisk risk) ] [ text <| formatID risk.id ] ]
            , td [] [ text <| showDate date ]
            , td [] [ text risk.title ]
            , td [] [ text risk.admin.comment ]
            , td [] <| badge risk.admin.status
            ]



-- set modal content


dialogConfig : Risk -> Dialog.Config Msg
dialogConfig risk =
    { closeMessage = Just ClosePopup
    , containerClass = Nothing
    , header = Just (h3 [] [ text ((formatID risk.id) ++ "  " ++ (risk.title)) ])
    , body =
        Just
            (table []
                [ tbody []
                    [ tr [ class "dashboard-modal-line" ]
                        [ th [] [ text "Description" ]
                        , td [] [ text risk.description ]
                        ]
                    , tr []
                        [ th [] [ text "Objectives" ]
                        , td [] [ text <| String.join ", " risk.objectives_at_stake ]
                        ]
                    , tr []
                        [ th [] [ text "Project Package" ]
                        , td [] [ text risk.project_package ]
                        ]
                    , tr []
                        [ th [] [ text "Type" ]
                        , td [] [ text risk.threat_type ]
                        ]
                    , tr []
                        [ th [] [ text "Cause" ]
                        , td [] [ text risk.cause ]
                        ]
                    , tr []
                        [ th [ class "dashboard-modal-impact-schedule-line" ] [ text "Impact on Schedule" ]
                        , td [] [ text risk.impact_schedule ]
                        ]
                    , tr []
                        [ th [] [ text "Impact on Cost" ]
                        , td [] [ text risk.impact_cost ]
                        ]
                    , tr []
                        [ th [] [ text "Impact on Perf." ]
                        , td [] [ text risk.impact_performance ]
                        ]
                    , tr []
                        [ th [] [ text "Probability" ]
                        , td [] [ text risk.probability ]
                        ]
                    , tr []
                        [ th [] [ text "Mitigation" ]
                        , td [] [ text risk.mitigation ]
                        ]
                    , tr []
                        [ th [] [ text "Author email" ]
                        , td [] [ text risk.author_email ]
                        ]
                    , tr []
                        [ th [ class "dashboard-modal-status-title" ] [ text "Status" ]
                        , td [ class "form-group dashboard-modal-status-input" ]
                            [ select
                                [ class "form-control form-control-dashboard-modal", onInput <| UpdateStatus ]
                                [ option
                                    []
                                    [ text risk.admin.status ]
                                , option
                                    []
                                    [ text "Pending" ]
                                , option
                                    []
                                    [ text "Assigned" ]
                                , option
                                    []
                                    [ text "Closed" ]
                                , option
                                    []
                                    [ text "Rejected" ]
                                ]
                            ]
                        ]
                    ]
                , tr []
                    [ th [ class "dashboard-modal-comment-title" ] [ text "Comment" ]
                    , td [ class "dashboard-modal-comment-input" ] [ textarea [ class "form-control form-control-dashboard-modal", rows 5, onInput UpdateComment ] [ text risk.admin.comment ] ]
                    ]
                ]
            )
    , footer =
        Just
            (button
                [ class "btn btn-success"
                , onClick ClosePopup
                ]
                [ text "OK" ]
            )
    }



-- Font Awesome badges for status display in the table


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

        "Assigned" ->
            [ i [ class "fa fa-user-circle", style [ ( "color", "blue" ) ] ] []
            , text " "
            , text status
            ]

        "Pending" ->
            [ i [ class "fa fa-spinner", style [ ( "color", "grey" ) ] ] []
            , text " "
            , text status
            ]

        _ ->
            [ text status ]



-- Record ID display format


formatID : String -> String
formatID id =
    String.toUpper ("RI-" ++ String.slice 0 3 id ++ "-" ++ String.slice 3 5 id)



-- Record date creation display format


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
        (zfill day)
            ++ "/"
            ++ (zfill month)
            ++ "/"
            ++ (toString year)



--++ " "
--++ (zfill hour)
--++ ":"
--++ (zfill minute)


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
