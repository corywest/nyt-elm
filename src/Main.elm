module Main exposing (main)

import Browser
import Html exposing (Html, div, text)



-- MODEL


type alias Model =
    { thing : String }


type Msg
    = NoOP


init : () -> ( Model, Cmd Msg )
init () =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { thing = "Hello" }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOP ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [] [ text "Hello" ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
