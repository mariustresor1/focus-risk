module LoginForm exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (Msg(..))


loginForm : Maybe String -> Maybe String -> Maybe String -> Html Msg
loginForm email password loginError =
    let
        error =
            case loginError of
                Nothing ->
                    div [] []

                Just error ->
                    div
                        [ class "alert alert-danger" ]
                        [ strong [] [ text "Login failed! " ]
                        , text error
                        ]
    in
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
                    , error
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
                                , value <| Maybe.withDefault "" email
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
                                , value <| Maybe.withDefault "" password
                                , placeholder ""
                                , id "password"
                                , onInput NewPassword
                                ]
                                []
                            ]
                        , div
                            [ class "row row--login" ]
                            [ a
                                [ href "#"
                                , class "btn blue-circle-button"
                                , onClick Login
                                ]
                                [ text "LOGIN" ]
                            ]
                        ]
                    ]
                ]
            ]
