module DashboardPage exposing (dashboardPage)

import Dialog
import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
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

        {- div [ class "container-fluid container-dashboard-table", id "risk" ]
           [ div [ class "row" ]
               [ div [ class "col-sm-12" ]
                   [ div [ class "white-box" ]
                       [ table []
                           [ tbody []
                               [ tr []
                                   [ th [] [ text "#" ]
                                   , td [] [ text <| formatID risk.id ]
                                   ]
                               , tr []
                                   [ th [] [ text "Title: " ]
                                   , td [] [ text risk.title ]
                                   ]
                               , tr []
                                   [ th [] [ text "Description: " ]
                                   , td [] [ text risk.description ]
                                   ]
                               , tr []
                                   [ th [] [ text "Objectives: " ]
                                   , td [] [ text <| String.join ", " risk.objectives_at_stake ]
                                   ]
                               , tr []
                                   [ th [] [ text "Project Package: " ]
                                   , td [] [ text risk.project_package ]
                                   ]
                               , tr []
                                   [ th [] [ text "Type: " ]
                                   , td [] [ text risk.threat_type ]
                                   ]
                               , tr []
                                   [ th [] [ text "Cause: " ]
                                   , td [] [ text risk.cause ]
                                   ]
                               , tr []
                                   [ th [] [ text "Impact Schedule: " ]
                                   , td [] [ text risk.impact_schedule ]
                                   ]
                               , tr []
                                   [ th [] [ text "Impact Cost: " ]
                                   , td [] [ text risk.impact_cost ]
                                   ]
                               , tr []
                                   [ th [] [ text "Impact Performance: " ]
                                   , td [] [ text risk.impact_performance ]
                                   ]
                               , tr []
                                   [ th [] [ text "Probability: " ]
                                   , td [] [ text risk.probability ]
                                   ]
                               , tr []
                                   [ th [] [ text "Mitigation: " ]
                                   , td [] [ text risk.mitigation ]
                                   ]
                               ]
                           ]
                       ]
                   ]
               ]
           ]
        -}
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
            , displayRisk
            ]



-- Creation of the table of risks and opportunities


tableRow : Risk -> Html Msg
tableRow risk =
    let
        date =
            DateTime.fromTimestamp <| toFloat risk.last_modified
    in
        tr []
            [ td [] [ a [ href "#risk", onClick (SelectRisk risk) ] [ text <| formatID risk.id ] ]
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
    , header = Just (h3 [] [ text ("Uncertainty ID: " ++ (formatID risk.id)) ]) -- Remplacer par <| formatID risk.id
    , body = Just (text ("Title: " ++ (toString risk.title)))
    , footer =
        Just
            (button
                [ class "btn btn-success"
                , onClick ClosePopup
                ]
                [ text "OK" ]
            )
    }



-- Font Awesome badges for status display


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
            ++ " "
            ++ (zfill hour)
            ++ ":"
            ++ (zfill minute)


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
