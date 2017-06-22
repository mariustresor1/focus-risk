module ThreatForm exposing (..)

import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Set


updateThreatForm : ThreatInput -> ThreatFormData -> String -> ThreatFormData
updateThreatForm fieldType threatForm value =
    -- case fieldType of
    case fieldType of
        ThreatObjectives ->
            if Set.member value threatForm.threat_objectives_at_stake then
                { threatForm
                    | threat_objectives_at_stake = Set.remove value threatForm.threat_objectives_at_stake
                }
            else
                { threatForm
                    | threat_objectives_at_stake = Set.insert value threatForm.threat_objectives_at_stake
                }

        ThreatProjectPackage ->
            { threatForm | threat_project_package = value }

        ThreatType ->
            { threatForm | threat_type = value }

        ThreatDescription ->
            { threatForm | threat_description = value }

        ThreatTitle ->
            { threatForm | threat_title = value }

        ThreatCause ->
            { threatForm | threat_cause = value }

        ThreatImpactSchedule ->
            { threatForm | threat_impact_schedule = value }

        ThreatImpactCost ->
            { threatForm | threat_impact_cost = value }

        ThreatImpactPerformance ->
            { threatForm | threat_impact_performance = value }

        ThreatProbability ->
            { threatForm | threat_probability = value }

        ThreatMitigation ->
            { threatForm | threat_mitigation = value }


formIsComplete : ThreatFormData -> Bool
formIsComplete formData =
    formData.threat_objectives_at_stake
        /= Set.empty
        && formData.threat_project_package
        /= ""
        && formData.threat_type
        /= ""
        && formData.threat_description
        /= ""
        && formData.threat_title
        /= ""
        && formData.threat_cause
        /= ""
        && formData.threat_impact_schedule
        /= ""
        && formData.threat_impact_cost
        /= ""
        && formData.threat_impact_performance
        /= ""
        && formData.threat_probability
        /= ""
        && formData.threat_mitigation
        /= ""


threatForm : Maybe String -> Html Msg
threatForm threatFormError =
    let
        error =
            case threatFormError of
                Nothing ->
                    div [] []

                Just error ->
                    div
                        [ class "alert alert-danger" ]
                        [ strong [] [ text "Threat Form Submission failed! " ]
                        , text error
                        ]
    in
        div []
            [ div
                [ class "block block--declare-header" ]
                [ div
                    [ class "container container--threat-introduction" ]
                    [ h1
                        []
                        [ text "📋 Identify a threat" ]
                    , p
                        [ class "lead" ]
                        [ text "Identifying and understanding the uncertainties that could alter the organization is the first step to Risk Management and to the implementation of a successful long term strategy." ]
                    ]
                ]
            , div
                [ class "block" ]
                [ div
                    [ class "container" ]
                    [ div
                        [ class "row" ]
                        [ h2
                            []
                            [ text "Describe the threat "
                            , span
                                [ class "num-section" ]
                                [ text "(1/5)" ]
                            ]
                        ]
                    , div
                        [ class "row" ]
                        [ error
                        , p
                            []
                            [ text "Each threat must be identified against the specific objectives of the organization as well as properly described, qualified and quantified." ]
                        , p
                            []
                            [ text "Which objective(s) of the organisation does the risk impact?" ]
                        , div
                            [ class "checkbox" ]
                            [ label
                                []
                                [ input
                                    [ type_ "checkbox", onClick <| ThreatFieldChange ThreatObjectives "Finish on time" ]
                                    []
                                , text
                                    "Finish on time"
                                ]
                            ]
                        , div
                            [ class "checkbox" ]
                            [ label
                                []
                                [ input
                                    [ type_ "checkbox", onClick <| ThreatFieldChange ThreatObjectives "Within costs" ]
                                    []
                                , text "Within costs"
                                ]
                            ]
                        , div
                            [ class "checkbox" ]
                            [ label
                                []
                                [ input
                                    [ type_ "checkbox", onClick <| ThreatFieldChange ThreatObjectives "High Quality" ]
                                    []
                                , text "High Quality"
                                ]
                            ]
                        , div
                            [ class "checkbox" ]
                            [ label
                                []
                                [ input
                                    [ type_ "checkbox", onClick <| ThreatFieldChange ThreatObjectives "Respect HSE guidelines" ]
                                    []
                                , text
                                    "Respect HSE guidelines"
                                ]
                            ]
                        ]
                    , div
                        [ class "row" ]
                        [ p
                            []
                            [ text "Which project package is in charge?" ]
                        , div
                            [ class "form-group" ]
                            [ select
                                [ class "form-control", id "sel1", onInput <| ThreatFieldChange ThreatProjectPackage ]
                                [ option
                                    []
                                    [ text "----" ]
                                , option
                                    []
                                    [ text "Human resources" ]
                                , option
                                    []
                                    [ text "Finance" ]
                                , option
                                    []
                                    [ text "Safety" ]
                                , option
                                    []
                                    [ text "Sales" ]
                                , option
                                    []
                                    [ text "Project Management Team" ]
                                , option
                                    []
                                    [ text "Topside EPC" ]
                                , option
                                    []
                                    [ text "Process" ]
                                , option
                                    []
                                    [ text "Civil work" ]
                                , option
                                    []
                                    [ text "Installation" ]
                                , option
                                    []
                                    [ text "Fields Ops" ]
                                ]
                            ]
                        ]
                    , div
                        [ class "row" ]
                        [ p
                            []
                            [ text "What type of risk is it?" ]
                        , p
                            [ class "form-legends-links" ]
                            [ text "For more details, refer to the "
                            , a
                                [ href "" ]
                                [ text "Risk Breakdown Structure." ]
                            ]
                        , div
                            [ class "form-group" ]
                            [ select
                                [ class "form-control", onInput <| ThreatFieldChange ThreatType ]
                                [ option
                                    []
                                    [ text "----" ]
                                , option
                                    []
                                    [ text "Contract" ]
                                , option
                                    []
                                    [ text "Outsourcing" ]
                                , option
                                    []
                                    [ text "Politics" ]
                                , option
                                    []
                                    [ text "Organization" ]
                                , option
                                    []
                                    [ text "Construction" ]
                                , option
                                    []
                                    [ text "Installation" ]
                                , option
                                    []
                                    [ text "Contract" ]
                                , option
                                    []
                                    [ text "Procurement" ]
                                , option
                                    []
                                    [ text "Logistics" ]
                                , option
                                    []
                                    [ text "Quality" ]
                                , option
                                    []
                                    [ text "Safety" ]
                                ]
                            ]
                        ]
                    , div
                        [ class "row" ]
                        [ p
                            []
                            [ text "Describe what is this risk about?" ]
                        , div
                            [ class "form-group" ]
                            [ textarea
                                [ class "form-control", rows 5, placeholder "Risk description", id "comment", onInput <| ThreatFieldChange ThreatDescription ]
                                []
                            ]
                        ]
                    ]
                ]
            , div
                [ class "block" ]
                [ div
                    [ class "container" ]
                    [ h2
                        []
                        [ text "Define a title "
                        , span
                            [ class "num-section" ]
                            [ text "(2/5)" ]
                        ]
                    , p
                        []
                        [ text "Choose a descriptive title that allows quickly understand the impact and context of the identified risk (100 characters max)." ]
                    , div
                        [ class "form-group" ]
                        [ input
                            [ class "form-control", placeholder "Ex: Subcontractor not able to deliver on time", id "usr", onInput <| ThreatFieldChange ThreatTitle ]
                            []
                        ]
                    ]
                ]
            , div
                [ class "block" ]
                [ div
                    [ class "container" ]
                    [ h2
                        []
                        [ text "Identify the cause "
                        , span
                            [ class "num-section" ]
                            [ text "(3/5)" ]
                        ]
                    , p
                        []
                        [ text "Each risk must have an identified cause already existing otherwise it is considered as a fear or a concern but not as a risk. The cause has to be directly linked to the risk." ]
                    , div
                        [ class "form-group" ]
                        [ textarea
                            [ class "form-control", rows 5, placeholder "Ex: The operator is operating in overcapacity", id "comment", onInput <| ThreatFieldChange ThreatCause ]
                            []
                        ]
                    ]
                ]
            , div
                [ class "block" ]
                [ div
                    [ class "container container--riskmatrix" ]
                    [ div
                        [ class "row" ]
                        [ h2
                            []
                            [ text "Assess impact and probability "
                            , span
                                [ class "num-section" ]
                                [ text "(4/5)" ]
                            ]
                        , p
                            []
                            [ text "To prioritise risks and better allocate resources to control them, we use a "
                            , a
                                [ href "" ]
                                [ text "Risk Assessment Matrix" ]
                            , text ". This matrix interacts probability and consequences to rate each individual risk. Probability and consequences are scaled on project objectives following pre-defined ranges."
                            ]
                        , p
                            []
                            [ text "Please provide an estimate of the impact of the uncertainty on:" ]
                        ]
                    , div
                        [ class "row container--riskmatrix--radiobox" ]
                        [ div
                            [ class "col-sm-12 col-md-4" ]
                            [ p
                                [ class "labelperso" ]
                                [ text "Schedule" ]
                            , div
                                []
                                [ div
                                    [ class "radio" ]
                                    [ label
                                        []
                                        [ input
                                            [ type_ "radio", name "schedule", onClick <| ThreatFieldChange ThreatImpactSchedule "Delay < 1 week" ]
                                            []
                                        , text "Delay < 1 week"
                                        ]
                                    ]
                                , div
                                    [ class "radio" ]
                                    [ label
                                        []
                                        [ input
                                            [ type_ "radio", name "schedule", onClick <| ThreatFieldChange ThreatImpactSchedule "1 week to 1 month" ]
                                            []
                                        , text "1 week to 1 month"
                                        ]
                                    ]
                                , div
                                    [ class "radio" ]
                                    [ label
                                        []
                                        [ input
                                            [ type_ "radio", name "schedule", onClick <| ThreatFieldChange ThreatImpactSchedule "1 month to 3 months" ]
                                            []
                                        , text "1 month to 3 months"
                                        ]
                                    ]
                                , div
                                    [ class "radio" ]
                                    [ label
                                        []
                                        [ input
                                            [ type_ "radio", name "schedule", onClick <| ThreatFieldChange ThreatImpactSchedule "> 3 months" ]
                                            []
                                        , text "> 3 months"
                                        ]
                                    ]
                                ]
                            ]
                        , div
                            [ class "col-sm-12 col-md-4" ]
                            [ p
                                [ class "labelperso" ]
                                [ text "Cost" ]
                            , div
                                []
                                [ div
                                    [ class "radio" ]
                                    [ label
                                        []
                                        [ input
                                            [ type_ "radio", name "cost", onClick <| ThreatFieldChange ThreatImpactCost "< 1 M$" ]
                                            []
                                        , text "< 1 M$"
                                        ]
                                    ]
                                , div
                                    [ class "radio" ]
                                    [ label
                                        []
                                        [ input
                                            [ type_ "radio", name "cost", onClick <| ThreatFieldChange ThreatImpactCost "1 M$ to 5 M$" ]
                                            []
                                        , text "1 M$ to 5 M$"
                                        ]
                                    ]
                                , div
                                    [ class "radio" ]
                                    [ label
                                        []
                                        [ input
                                            [ type_ "radio", name "cost", onClick <| ThreatFieldChange ThreatImpactCost "5 M$ to 20 M$" ]
                                            []
                                        , text "5 M$ to 20 M$"
                                        ]
                                    ]
                                , div
                                    [ class "radio" ]
                                    [ label
                                        []
                                        [ input
                                            [ type_ "radio", name "cost", onClick <| ThreatFieldChange ThreatImpactCost "> 20 M$" ]
                                            []
                                        , text "> 20 M$"
                                        ]
                                    ]
                                ]
                            ]
                        , div
                            [ class "col-sm-12 col-md-4" ]
                            [ p
                                [ class "labelperso" ]
                                [ text "Performance" ]
                            , div
                                []
                                [ div
                                    [ class "radio" ]
                                    [ label
                                        []
                                        [ input
                                            [ type_ "radio", name "Performance", onClick <| ThreatFieldChange ThreatImpactPerformance "Negligible" ]
                                            []
                                        , text "Negligible"
                                        ]
                                    ]
                                , div
                                    [ class "radio" ]
                                    [ label
                                        []
                                        [ input
                                            [ type_ "radio", name "Performance", onClick <| ThreatFieldChange ThreatImpactPerformance "Small" ]
                                            []
                                        , text "Small"
                                        ]
                                    ]
                                , div
                                    [ class "radio" ]
                                    [ label
                                        []
                                        [ input
                                            [ type_ "radio", name "Performance", onClick <| ThreatFieldChange ThreatImpactPerformance "Substantial" ]
                                            []
                                        , text "Substantial"
                                        ]
                                    ]
                                , div
                                    [ class "radio" ]
                                    [ label
                                        []
                                        [ input
                                            [ type_ "radio", name "Performance", onClick <| ThreatFieldChange ThreatImpactPerformance "Huge" ]
                                            []
                                        , text "Huge"
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    , div
                        [ class "row" ]
                        [ p
                            []
                            [ text "And guess the probability of occurrence:" ]
                        , div
                            [ class "col-sm-12 col-md-4" ]
                            [ div
                                []
                                [ div
                                    [ class "radio" ]
                                    [ label
                                        []
                                        [ input
                                            [ type_ "radio", name "Probability", onClick <| ThreatFieldChange ThreatProbability "Low (< 5%)" ]
                                            []
                                        , text "Low (< 5%)"
                                        ]
                                    ]
                                , div
                                    [ class "radio" ]
                                    [ label
                                        []
                                        [ input
                                            [ type_ "radio", name "Probability", onClick <| ThreatFieldChange ThreatProbability "Medium (5% to 30%)" ]
                                            []
                                        , text
                                            "Medium (5% to 30%)"
                                        ]
                                    ]
                                , div
                                    [ class "radio" ]
                                    [ label
                                        []
                                        [ input
                                            [ type_ "radio", name "Probability", onClick <| ThreatFieldChange ThreatProbability "High (30% to 60%)" ]
                                            []
                                        , text
                                            "High (30% to 60%)"
                                        ]
                                    ]
                                , div
                                    [ class "radio" ]
                                    [ label
                                        []
                                        [ input
                                            [ type_ "radio", name "Probability", onClick <| ThreatFieldChange ThreatProbability "Very high (> 60%)" ]
                                            []
                                        , text
                                            "Very high (> 60%)"
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            , div
                [ class "block" ]
                [ div
                    [ class "container contrainer--mitigation" ]
                    [ div
                        [ class "row" ]
                        [ h2
                            []
                            [ text "Recommend mitigation "
                            , span
                                [ class "num-section" ]
                                [ text "(5/5)" ]
                            ]
                        , p
                            []
                            [ text "Please recommend action to transfer, reduce, or eliminate the negative impact / or increase the chance of opportunity." ]
                        ]
                    , div
                        [ class "row" ]
                        [ div
                            [ class "form-group" ]
                            [ textarea
                                [ class "form-control", rows 5, placeholder "Ex: Organise workshop with contractors and production team to review production capacity.", id "comment", onInput <| ThreatFieldChange ThreatMitigation ]
                                []
                            ]
                        ]
                    ]
                , div
                    [ class "container container--button" ]
                    [ div
                        [ class "row " ]
                        [ div
                            [ class "col-md-6 container--button--space" ]
                            [ a
                                [ href "#"
                                , class "btn blue-circle-button"
                                , onClick SubmitThreatForm
                                ]
                                [ text "Submit" ]
                            ]
                        , div
                            [ class "col-md-6 " ]
                            [ a
                                [ href "#"
                                , class "btn blue-circle-button"
                                , onClick GoToDashboardPage
                                ]
                                [ text "Save for later" ]
                            ]
                        ]
                    ]
                ]
            ]


opportunityForm : Html Msg
opportunityForm =
    div []
        [ div
            [ class "block block--declare-header" ]
            [ div
                [ class "container container--threat-introduction" ]
                [ h1
                    []
                    [ text "📋 Identify an opportunity" ]
                , p
                    [ class "lead" ]
                    [ text "Identifying and understanding the uncertainties that could alter the organization is the first step to Risk Management and to the implementation of a successful long term strategy." ]
                ]
            ]
        , div
            [ class "block" ]
            [ div
                [ class "container" ]
                [ div
                    [ class "row" ]
                    [ h2
                        []
                        [ text "Describe the opportunity"
                        , span
                            [ class "num-section" ]
                            [ text "(1/5)" ]
                        ]
                    ]
                , div
                    [ class "row" ]
                    [ p
                        []
                        [ text "Each threat must be identified against the specific objectives of the organization as well as properly described, qualified and quantified." ]
                    , p
                        []
                        [ text "Which objective(s) of the organisation does the opportunity impact?" ]
                    , div
                        [ class "checkbox" ]
                        [ label
                            []
                            [ input
                                [ type_ "checkbox", onClick <| ThreatFieldChange ThreatObjectives "Finish on time" ]
                                []
                            , text
                                "Finish on time"
                            ]
                        ]
                    , div
                        [ class "checkbox" ]
                        [ label
                            []
                            [ input
                                [ type_ "checkbox", onClick <| ThreatFieldChange ThreatObjectives "Within costs" ]
                                []
                            , text "Within costs"
                            ]
                        ]
                    , div
                        [ class "checkbox" ]
                        [ label
                            []
                            [ input
                                [ type_ "checkbox", onClick <| ThreatFieldChange ThreatObjectives "High Quality" ]
                                []
                            , text "High Quality"
                            ]
                        ]
                    , div
                        [ class "checkbox" ]
                        [ label
                            []
                            [ input
                                [ type_ "checkbox", onClick <| ThreatFieldChange ThreatObjectives "Respect HSE guidelines" ]
                                []
                            , text
                                "Respect HSE guidelines"
                            ]
                        ]
                    ]
                , div
                    [ class "row" ]
                    [ p
                        []
                        [ text "Which project package is in charge?" ]
                    , div
                        [ class "form-group" ]
                        [ select
                            [ class "form-control", id "sel1", onInput <| ThreatFieldChange ThreatProjectPackage ]
                            [ option
                                []
                                [ text "----" ]
                            , option
                                []
                                [ text "Human resources" ]
                            , option
                                []
                                [ text "Finance" ]
                            , option
                                []
                                [ text "Safety" ]
                            , option
                                []
                                [ text "Sales" ]
                            , option
                                []
                                [ text "Project Management Team" ]
                            , option
                                []
                                [ text "Topside EPC" ]
                            , option
                                []
                                [ text "Process" ]
                            , option
                                []
                                [ text "Civil work" ]
                            , option
                                []
                                [ text "Installation" ]
                            , option
                                []
                                [ text "Fields Ops" ]
                            ]
                        ]
                    ]
                , div
                    [ class "row" ]
                    [ p
                        []
                        [ text "What type of opportunity is it?" ]
                    , p
                        [ class "form-legends-links" ]
                        [ text "For more details, refer to the "
                        , a
                            [ href "" ]
                            [ text "Risk Breakdown Structure." ]
                        ]
                    , div
                        [ class "form-group" ]
                        [ select
                            [ class "form-control", onInput <| ThreatFieldChange ThreatType ]
                            [ option
                                []
                                [ text "----" ]
                            , option
                                []
                                [ text "Contract" ]
                            , option
                                []
                                [ text "Outsourcing" ]
                            , option
                                []
                                [ text "Politics" ]
                            , option
                                []
                                [ text "Organization" ]
                            , option
                                []
                                [ text "Construction" ]
                            , option
                                []
                                [ text "Installation" ]
                            , option
                                []
                                [ text "Contract" ]
                            , option
                                []
                                [ text "Procurement" ]
                            , option
                                []
                                [ text "Logistics" ]
                            , option
                                []
                                [ text "Quality" ]
                            , option
                                []
                                [ text "Safety" ]
                            ]
                        ]
                    ]
                , div
                    [ class "row" ]
                    [ p
                        []
                        [ text "Describe what is this opportunity about?" ]
                    , div
                        [ class "form-group" ]
                        [ textarea
                            [ class "form-control", rows 5, placeholder "Opportunity description", id "comment", onInput <| ThreatFieldChange ThreatDescription ]
                            []
                        ]
                    ]
                ]
            ]
        , div
            [ class "block" ]
            [ div
                [ class "container" ]
                [ h2
                    []
                    [ text "Define a title"
                    , span
                        [ class "num-section" ]
                        [ text "(2/5)" ]
                    ]
                , p
                    []
                    [ text "Choose a descriptive title that allows quickly understand the impact and context of the identified opportunity (100 characters max)." ]
                , div
                    [ class "form-group" ]
                    [ input
                        [ class "form-control", placeholder "Ex: Subcontractor not able to deliver on time", id "usr", onInput <| ThreatFieldChange ThreatTitle ]
                        []
                    ]
                ]
            ]
        , div
            [ class "block" ]
            [ div
                [ class "container" ]
                [ h2
                    []
                    [ text "Identify the cause"
                    , span
                        [ class "num-section" ]
                        [ text "(3/5)" ]
                    ]
                , p
                    []
                    [ text "Each risk must have an identified cause already existing otherwise it is considered as a fear or a concern but not as a risk. The cause has to be directly linked to the risk." ]
                , div
                    [ class "form-group" ]
                    [ textarea
                        [ class "form-control", rows 5, placeholder "Ex: The operator is operating in overcapacity", id "comment", onInput <| ThreatFieldChange ThreatCause ]
                        []
                    ]
                ]
            ]
        , div
            [ class "block" ]
            [ div
                [ class "container container--riskmatrix" ]
                [ div
                    [ class "row" ]
                    [ h2
                        []
                        [ text "Assess impact and probability"
                        , span
                            [ class "num-section" ]
                            [ text "(4/5)" ]
                        ]
                    , p
                        []
                        [ text "To prioritise opportunities and better allocate resources to support them, we use a"
                        , a
                            [ href "" ]
                            [ text "Opportunity Assessment Matrix" ]
                        , text ". This matrix interacts probability and consequences to rate each individual opportunity. Probability and consequences are scaled on project objectives following pre-defined ranges."
                        ]
                    , p
                        []
                        [ text "Please provide an estimate of the impact of the uncertainty on:" ]
                    ]
                , div
                    [ class "row container--riskmatrix--radiobox" ]
                    [ div
                        [ class "col-sm-12 col-md-4" ]
                        [ p
                            [ class "labelperso" ]
                            [ text "Schedule" ]
                        , div
                            []
                            [ div
                                [ class "radio" ]
                                [ label
                                    []
                                    [ input
                                        [ type_ "radio", name "schedule", onClick <| ThreatFieldChange ThreatImpactSchedule "Delay < 1 week" ]
                                        []
                                    , text "Delay < 1 week"
                                    ]
                                ]
                            , div
                                [ class "radio" ]
                                [ label
                                    []
                                    [ input
                                        [ type_ "radio", name "schedule", onClick <| ThreatFieldChange ThreatImpactSchedule "1 week to 1 month" ]
                                        []
                                    , text "1 week to 1 month"
                                    ]
                                ]
                            , div
                                [ class "radio" ]
                                [ label
                                    []
                                    [ input
                                        [ type_ "radio", name "schedule", onClick <| ThreatFieldChange ThreatImpactSchedule "1 month to 3 months" ]
                                        []
                                    , text "1 month to 3 months"
                                    ]
                                ]
                            , div
                                [ class "radio" ]
                                [ label
                                    []
                                    [ input
                                        [ type_ "radio", name "schedule", onClick <| ThreatFieldChange ThreatImpactSchedule "> 3 months" ]
                                        []
                                    , text "> 3 months"
                                    ]
                                ]
                            ]
                        ]
                    , div
                        [ class "col-sm-12 col-md-4" ]
                        [ p
                            [ class "labelperso" ]
                            [ text "Cost" ]
                        , div
                            []
                            [ div
                                [ class "radio" ]
                                [ label
                                    []
                                    [ input
                                        [ type_ "radio", name "cost", onClick <| ThreatFieldChange ThreatImpactCost "< 1 M$" ]
                                        []
                                    , text "< 1 M$"
                                    ]
                                ]
                            , div
                                [ class "radio" ]
                                [ label
                                    []
                                    [ input
                                        [ type_ "radio", name "cost", onClick <| ThreatFieldChange ThreatImpactCost "1 M$ to 5 M$" ]
                                        []
                                    , text "1 M$ to 5 M$"
                                    ]
                                ]
                            , div
                                [ class "radio" ]
                                [ label
                                    []
                                    [ input
                                        [ type_ "radio", name "cost", onClick <| ThreatFieldChange ThreatImpactCost "5 M$ to 20 M$" ]
                                        []
                                    , text "5 M$ to 20 M$"
                                    ]
                                ]
                            , div
                                [ class "radio" ]
                                [ label
                                    []
                                    [ input
                                        [ type_ "radio", name "cost", onClick <| ThreatFieldChange ThreatImpactCost "> 20 M$" ]
                                        []
                                    , text "> 20 M$"
                                    ]
                                ]
                            ]
                        ]
                    , div
                        [ class "col-sm-12 col-md-4" ]
                        [ p
                            [ class "labelperso" ]
                            [ text "Performance" ]
                        , div
                            []
                            [ div
                                [ class "radio" ]
                                [ label
                                    []
                                    [ input
                                        [ type_ "radio", name "Performance", onClick <| ThreatFieldChange ThreatImpactPerformance "Negligible" ]
                                        []
                                    , text "Negligible"
                                    ]
                                ]
                            , div
                                [ class "radio" ]
                                [ label
                                    []
                                    [ input
                                        [ type_ "radio", name "Performance", onClick <| ThreatFieldChange ThreatImpactPerformance "Small" ]
                                        []
                                    , text "Small"
                                    ]
                                ]
                            , div
                                [ class "radio" ]
                                [ label
                                    []
                                    [ input
                                        [ type_ "radio", name "Performance", onClick <| ThreatFieldChange ThreatImpactPerformance "Substantial" ]
                                        []
                                    , text "Substantial"
                                    ]
                                ]
                            , div
                                [ class "radio" ]
                                [ label
                                    []
                                    [ input
                                        [ type_ "radio", name "Performance", onClick <| ThreatFieldChange ThreatImpactPerformance "Huge" ]
                                        []
                                    , text "Huge"
                                    ]
                                ]
                            ]
                        ]
                    ]
                , div
                    [ class "row" ]
                    [ p
                        []
                        [ text "And guess the probability of occurrence:" ]
                    , div
                        [ class "col-sm-12 col-md-4" ]
                        [ div
                            []
                            [ div
                                [ class "radio" ]
                                [ label
                                    []
                                    [ input
                                        [ type_ "radio", name "Probability", onClick <| ThreatFieldChange ThreatProbability "Low (< 5%)" ]
                                        []
                                    , text "Low (< 5%)"
                                    ]
                                ]
                            , div
                                [ class "radio" ]
                                [ label
                                    []
                                    [ input
                                        [ type_ "radio", name "Probability", onClick <| ThreatFieldChange ThreatProbability "Medium (5% to 30%)" ]
                                        []
                                    , text
                                        "Medium (5% to 30%)"
                                    ]
                                ]
                            , div
                                [ class "radio" ]
                                [ label
                                    []
                                    [ input
                                        [ type_ "radio", name "Probability", onClick <| ThreatFieldChange ThreatProbability "High (30% to 60%)" ]
                                        []
                                    , text
                                        "High (30% to 60%)"
                                    ]
                                ]
                            , div
                                [ class "radio" ]
                                [ label
                                    []
                                    [ input
                                        [ type_ "radio", name "Probability", onClick <| ThreatFieldChange ThreatProbability "Very high (> 60%)" ]
                                        []
                                    , text
                                        "Very high (> 60%)"
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        , div
            [ class "block" ]
            [ div
                [ class "container contrainer--mitigation" ]
                [ div
                    [ class "row" ]
                    [ h2
                        []
                        [ text "Recommend mitigation"
                        , span
                            [ class "num-section" ]
                            [ text "(5/5)" ]
                        ]
                    , p
                        []
                        [ text "Please recommend action to increase the positive impact or the chance of occurring." ]
                    ]
                , div
                    [ class "row" ]
                    [ div
                        [ class "form-group" ]
                        [ textarea
                            [ class "form-control", rows 5, placeholder "Ex: Organise workshop with contractors and production team to review production capacity.", id "comment", onInput <| ThreatFieldChange ThreatMitigation ]
                            []
                        ]
                    ]
                ]
            , div
                [ class "container container--button" ]
                [ div
                    [ class "row " ]
                    [ div
                        [ class "col-md-6 container--button--space" ]
                        [ a
                            [ href "#"
                            , class "btn blue-circle-button"
                            , onClick SubmitThreatForm
                            ]
                            [ text "Submit" ]
                        ]
                    , div
                        [ class "col-md-6 " ]
                        [ a
                            [ href "#"
                            , class "btn blue-circle-button"
                            , onClick GoToDashboardPage
                            ]
                            [ text "Save for later" ]
                        ]
                    ]
                ]
            ]
        ]
