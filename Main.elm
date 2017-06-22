module Main exposing (..)

import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Kinto
import Set
import LoginForm exposing (loginForm)


init : ( Model, Cmd Msg )
init =
    ( { currentPage = LoginPage
      , email = Nothing
      , password = Nothing
      , error = Nothing
      , threatForm = emptyThreatForm
      }
    , Cmd.none
    )



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewEmail email ->
            ( { model | email = Just email }, Cmd.none )

        NewPassword password ->
            ( { model | password = Just password }, Cmd.none )

        Login ->
            case model.email of
                Nothing ->
                    ( { model | error = Just "Please enter an email" }, Cmd.none )

                Just email ->
                    case model.password of
                        Nothing ->
                            ( { model | error = Just "Please enter a password" }, Cmd.none )

                        Just password ->
                            ( model, validateLogin email password )

        FetchRecordsResponse (Ok records) ->
            ( { model | error = Nothing, currentPage = HomePage }, Cmd.none )

        FetchRecordsResponse (Err (Kinto.KintoError 401 _ error)) ->
            ( { model | error = Just "Bad email and password. Try again." }, Cmd.none )

        FetchRecordsResponse (Err (Kinto.KintoError 403 _ error)) ->
            ( { model | error = Just "Call your administrator. The site is not configured yet." }, Cmd.none )

        FetchRecordsResponse (Err error) ->
            model |> updateError error

        ThreatFieldChange fieldType value ->
            let
                _ =
                    Debug.log "fieldType" fieldType
            in
                ( { model | threatForm = updateThreatForm fieldType model.threatForm value }, Cmd.none )

        GoToConfirmationPage ->
            ( { model | currentPage = ConfirmationPage }, Cmd.none )

        GoToDashboardPage ->
            ( { model | currentPage = DashboardPage }, Cmd.none )

        GoToHomePage ->
            ( { model | currentPage = HomePage }, Cmd.none )

        GoToLoginPage ->
            ( { model | currentPage = LoginPage }, Cmd.none )

        GoToOpportunityForm ->
            ( { model | currentPage = OpportunityForm }, Cmd.none )

        GoToThreatForm ->
            ( { model | currentPage = ThreatForm }, Cmd.none )

        SubmitThreatForm ->
            case ( model.email, model.password ) of
                ( Just email, Just password ) ->
                    ( model, submitThreatForm email password model.threatForm )

                _ ->
                    ( { model | currentPage = LoginPage }, Cmd.none )

        CreateRecordResponse (Ok _) ->
            ( { model | currentPage = ConfirmationPage }, Cmd.none )

        CreateRecordResponse (Err error) ->
            model |> updateError error


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


updateError : error -> Model -> ( Model, Cmd Msg )
updateError error model =
    ( { model | error = Just <| toString error }, Cmd.none )


client : String -> String -> Kinto.Client
client email password =
    Kinto.client
        "https://focus-risk.alwaysdata.net/v1/"
        (Kinto.Basic email password)


validateLogin : String -> String -> Cmd Msg
validateLogin email password =
    client email password
        |> Kinto.getList recordResource
        |> Kinto.sortBy [ "-last_modified" ]
        |> Kinto.send FetchRecordsResponse


recordResource : Kinto.Resource Record
recordResource =
    Kinto.recordResource "focus" "threats" decodeRecord


decodeRecord : Decode.Decoder Record
decodeRecord =
    (Decode.map2 Record
        (Decode.field "id" Decode.string)
        (Decode.field "last_modified" Decode.int)
    )


encodeFormData : ThreatFormData -> Encode.Value
encodeFormData formData =
    Encode.object
        [ ( "objectives_at_stake", Encode.list <| List.map Encode.string <| Set.toList formData.threat_objectives_at_stake )
        , ( "project_package", Encode.string formData.threat_project_package )
        , ( "type", Encode.string formData.threat_type )
        , ( "description", Encode.string formData.threat_description )
        , ( "title", Encode.string formData.threat_title )
        , ( "cause", Encode.string formData.threat_cause )
        , ( "impact_schedule", Encode.string formData.threat_impact_schedule )
        , ( "impact_cost", Encode.string formData.threat_impact_cost )
        , ( "impact_performance", Encode.string formData.threat_impact_performance )
        , ( "probability", Encode.string formData.threat_probability )
        , ( "mitigation", Encode.string formData.threat_mitigation )
        ]


submitThreatForm : String -> String -> ThreatFormData -> Cmd Msg
submitThreatForm email password formData =
    let
        data =
            encodeFormData formData
    in
        client email password
            |> Kinto.create recordResource data
            |> Kinto.send CreateRecordResponse



-- View


view : Model -> Html Msg
view model =
    case model.currentPage of
        LoginPage ->
            loginForm model.error

        HomePage ->
            div []
                [ navigation model.currentPage
                , homePage
                ]

        ThreatForm ->
            div []
                [ navigation model.currentPage
                , threatForm
                ]

        OpportunityForm ->
            div []
                [ navigation model.currentPage
                , opportunityForm
                ]

        ConfirmationPage ->
            div []
                [ navigation model.currentPage
                , confirmationPage
                ]

        DashboardPage ->
            div []
                [ navigation model.currentPage
                , dashboardPage
                ]


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
                            [ href "" ]
                            [ text "Links to ISO 31000 and COSO Standards" ]
                        ]
                    , li
                        []
                        [ a
                            [ href "" ]
                            [ text "Links to Company Rules" ]
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


threatForm : Html Msg
threatForm =
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
                        [ text "Describe the threat"
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
                    [ text "Define a title"
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
                        [ text "Recommend mitigation"
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
                [ text "For any request or query about the process, you can contact your dedicated risk manager:"
                , a
                    [ href "mailto:contact@risk-focus.com" ]
                    [ text "contact@risk-focus.com." ]
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


dashboardPage : Html Msg
dashboardPage =
    div
        [ class "block" ]
        [ div
            [ class "container" ]
            [ h1
                []
                [ text "Dashboard" ]
            ]
        ]



-- Program


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }
