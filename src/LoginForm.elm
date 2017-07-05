module LoginForm exposing (..)

import Html exposing (div, input, button, form, h1, h2, h3, a, Html, text, img, strong)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (Msg(..))


-- view


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
                        [ img [ class "img-responsive", src "img/loyd.png", alt "" ] []
                        , h1 [] [ text "Focus" ]
                        , h2 [] [ text "Risk management" ]
                        , h3 [] [ text "Get involved!" ]
                        ]
                    , error
                    , div
                        [ class "col-md-6 left" ]
                        [ h1 [] [ text "LOGIN" ]
                        , Html.form [ onSubmit Login ]
                            [ div
                                [ class "form-group" ]
                                [ h2
                                    []
                                    [ text "USERNAME" ]
                                , input
                                    [ value <| Maybe.withDefault "" email
                                    , class "form-control"
                                    , placeholder ""
                                    , id "email"
                                    , onInput NewEmail
                                    ]
                                    []
                                , h2 [] [ text "PASSWORD" ]
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
                                [ button
                                    [ class "btn blue-circle-button"
                                    ]
                                    [ text "LOGIN" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
