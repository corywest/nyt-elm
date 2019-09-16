module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import Http
import Json.Decode exposing (Decoder, bool, decodeString, float, int, list, nullable, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)



-- MODEL


type alias Model =
    { feed : Maybe Feed
    }


type alias Feed =
    { results : List Movie
    }


type alias Movie =
    { displayTitle : String
    , headline : String
    , summaryShort : String
    , openingDate : String
    , photo : MoviePhoto
    }


type alias MoviePhoto =
    { src : String }


type Msg
    = LoadMovieFeed (Result Http.Error Feed)


init : () -> ( Model, Cmd Msg )
init () =
    ( initialModel, fetchMovies )


initialModel : Model
initialModel =
    { feed = Nothing }


fetchMovies : Cmd Msg
fetchMovies =
    Http.get
        { url = "https://api.nytimes.com/svc/movies/v2/reviews/search.json?api-key=QJK7PuKhn7lC6DtyAeDUzwQ7MpYV3bsp"
        , expect = Http.expectJson LoadMovieFeed feedDecoder
        }


feedDecoder : Decoder Feed
feedDecoder =
    succeed Feed
        |> required "results" (list movieDecoder)


movieDecoder : Decoder Movie
movieDecoder =
    succeed Movie
        |> required "display_title" string
        |> required "headline" string
        |> required "summary_short" string
        |> required "opening_date" string
        |> required "multimedia" moviePhotoDecoder


moviePhotoDecoder : Decoder MoviePhoto
moviePhotoDecoder =
    succeed MoviePhoto
        |> required "src" string



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadMovieFeed (Ok feed) ->
            ( { model | feed = Just feed }, Cmd.none )

        LoadMovieFeed (Err errorMessage) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [] [ text model.feed ]



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
