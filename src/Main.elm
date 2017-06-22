module Main exposing (..)

import Types exposing (..)
import Html exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Kinto
import Set
import LoginForm exposing (loginForm)
import NavigationBar exposing (navigation)
import ThreatForm exposing (updateThreatForm, threatForm, opportunityForm, formIsComplete)
import HomePage exposing (homePage)
import ConfirmationPage exposing (confirmationPage)
import DashboardPage exposing (dashboardPage)
import Json.Decode.Pipeline as JP


init : ( Model, Cmd Msg )
init =
    ( { currentPage = LoginPage
      , email = Nothing
      , password = Nothing
      , error = Nothing
      , threatForm = emptyThreatForm
      , risksPager = Nothing
      , nextPage = HomePage
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
                            let
                                client =
                                    getKintoClient email password
                            in
                                ( { model
                                    | risksPager = Just <| Kinto.emptyPager client recordResource
                                  }
                                , fetchRisksList client
                                )

        FetchRecordsResponse (Ok newPager) ->
            ( { model
                | error = Nothing
                , currentPage = model.nextPage
                , risksPager =
                    case model.risksPager of
                        Just pager ->
                            Just <| Kinto.updatePager newPager pager

                        Nothing ->
                            Just <| newPager
              }
            , Cmd.none
            )

        FetchRecordsResponse (Err (Kinto.KintoError 401 _ error)) ->
            ( { model | error = Just "Bad email and password. Try again.", password = Nothing }, Cmd.none )

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
            ( { model | currentPage = LoginPage, password = Nothing }, Cmd.none )

        GoToOpportunityForm ->
            ( { model | currentPage = OpportunityForm }, Cmd.none )

        GoToThreatForm ->
            ( { model | currentPage = ThreatForm }, Cmd.none )

        SubmitThreatForm ->
            case ( model.email, model.password ) of
                ( Just email, Just password ) ->
                    if formIsComplete model.threatForm then
                        ( model, submitThreatForm email password model.threatForm )
                    else
                        ( { model
                            | error = Just "Please make sure to fill all the fields."
                          }
                        , Cmd.none
                        )

                _ ->
                    ( { model | currentPage = LoginPage }, Cmd.none )

        CreateRecordResponse (Ok _) ->
            case ( model.email, model.password ) of
                ( Just email, Just password ) ->
                    let
                        client =
                            getKintoClient email password
                    in
                        ( { model
                            | risksPager = Just <| Kinto.emptyPager client recordResource
                            , currentPage = ConfirmationPage
                            , nextPage = ConfirmationPage
                          }
                        , fetchRisksList client
                        )

                _ ->
                    ( { model | currentPage = LoginPage }, Cmd.none )

        CreateRecordResponse (Err error) ->
            model |> updateError error


updateError : error -> Model -> ( Model, Cmd Msg )
updateError error model =
    ( { model | error = Just <| toString error }, Cmd.none )


getKintoClient : String -> String -> Kinto.Client
getKintoClient email password =
    Kinto.client
        "https://focus-risk.alwaysdata.net/v1/"
        (Kinto.Basic email password)


fetchRisksList : Kinto.Client -> Cmd Msg
fetchRisksList client =
    client
        |> Kinto.getList recordResource
        |> Kinto.sortBy [ "-last_modified" ]
        |> Kinto.send FetchRecordsResponse


recordResource : Kinto.Resource Risk
recordResource =
    Kinto.recordResource "focus" "threats" decodeRecord


decodeRecord : Decode.Decoder Risk
decodeRecord =
    JP.decode Risk
        |> JP.required "id" Decode.string
        |> JP.required "last_modified" Decode.int
        |> JP.required "title" Decode.string
        |> JP.optional "admin" decodeRiskAdmin { comment = "", status = "Pending" }


decodeRiskAdmin : Decode.Decoder RiskAdmin
decodeRiskAdmin =
    JP.decode RiskAdmin
        |> JP.optional "comment" Decode.string ""
        |> JP.required "status" Decode.string


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
        getKintoClient email password
            |> Kinto.create recordResource data
            |> Kinto.send CreateRecordResponse



-- View


view : Model -> Html Msg
view model =
    case model.currentPage of
        LoginPage ->
            loginForm model.email model.password model.error

        HomePage ->
            div []
                [ navigation model.currentPage
                , homePage
                ]

        ThreatForm ->
            div []
                [ navigation model.currentPage
                , threatForm model.error
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
            let
                page =
                    case model.risksPager of
                        Nothing ->
                            dashboardPage []

                        Just pager ->
                            dashboardPage pager.objects
            in
                div []
                    [ navigation model.currentPage
                    , page
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
