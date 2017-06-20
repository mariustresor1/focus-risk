module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Kinto


type alias Model =
    { email : Maybe String
    , password : Maybe String
    , error : Maybe String
    }


type Msg
    = NewEmail String
    | NewPassword String
    | Login
    | FetchRecordsResponse (Result Kinto.Error (Kinto.Pager Record))


type alias Record =
    { id : String
    , last_modified : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { email = Nothing, password = Nothing, error = Nothing }, Cmd.none )



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
            ( { model | error = Nothing }, Cmd.none )

        FetchRecordsResponse (Err error) ->
            model |> updateError error


updateError : error -> Model -> ( Model, Cmd Msg )
updateError error model =
    ( { model | error = Just <| toString error }, Cmd.none )


client : String -> String -> Kinto.Client
client email password =
    Kinto.client
        "https://kinto.dev.mozaws.net/v1/"
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



-- View


view : Model -> Html Msg
view model =
    div
        [ class "block block--login" ]
        [ div
            [ class "container container--login" ]
            [ div
                [ class "row row--login" ]
                [ div
                    [ class "col-md-6 right" ]
                    [ img
                        [ class "img-responsive", src "img/loyd.png", alt "" ]
                        []
                    , h1
                        []
                        [ text "Focus" ]
                    , h2
                        []
                        [ text "Risk management" ]
                    , h3
                        []
                        [ text "Get involved!" ]
                    ]
                , div
                    [ class "col-md-6 left" ]
                    [ h1
                        []
                        [ text "LOGIN" ]
                    , div
                        [ class "form-group" ]
                        [ h2
                            []
                            [ text "EMAIL ADDRESS" ]
                        , input
                            [ type_ "email"
                            , class "form-control"
                            , placeholder ""
                            , id "email"
                            , onInput NewEmail
                            ]
                            []
                        , h2
                            []
                            [ text "PASSWORD" ]
                        , input
                            [ type_ "password"
                            , class "form-control"
                            , placeholder ""
                            , id "password"
                            , onInput NewPassword
                            ]
                            []
                        ]
                    , div
                        [ class "row row--login" ]
                        [ a
                            [ href "./home.html"
                            , class "btn blue-circle-button"
                            , onClick Login
                            ]
                            [ text "LOGIN" ]
                        ]
                    ]
                ]
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
