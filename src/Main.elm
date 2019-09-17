module Main exposing (main)

import Browser
import Debug exposing (log)
import Html exposing (Html, div, li, text, ul)
import Html.Attributes exposing (class)
import Http
import Json.Decode exposing (Decoder, bool, decodeString, float, int, list, nullable, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)



-- MODEL


type alias Model =
    { feed : Maybe Feed
    , error : Maybe Http.Error
    }


type alias Feed =
    { results : List Movie }


type alias Movie =
    { displayTitle : String
    , headline : String
    , summaryShort : String
    , publicationDate : String
    , multimedia : MoviePhoto
    }


type alias MoviePhoto =
    { src : String }


type Msg
    = LoadMovieFeed (Result Http.Error Feed)
    | LoadMoreMovies (Result Http.Error Feed)


init : () -> ( Model, Cmd Msg )
init () =
    ( initialModel, Cmd.batch [ fetchMovies, fetchMoreMovies ] )


initialModel : Model
initialModel =
    { feed = Nothing
    , error = Nothing
    }


fetchMovies : Cmd Msg
fetchMovies =
    Http.get
        { url = "https://api.nytimes.com/svc/movies/v2/reviews/search.json?api-key=QJK7PuKhn7lC6DtyAeDUzwQ7MpYV3bsp"
        , expect = Http.expectJson LoadMovieFeed resultDecoder
        }


fetchMoreMovies : Cmd Msg
fetchMoreMovies =
    Http.get
        { url = "https://api.nytimes.com/svc/movies/v2/reviews/search.json?api-key=QJK7PuKhn7lC6DtyAeDUzwQ7MpYV3bsp"
        , expect = Http.expectJson LoadMoreMovies resultDecoder
        }


resultDecoder : Decoder Feed
resultDecoder =
    succeed Feed
        |> required "results" (list movieDecoder)


movieDecoder : Decoder Movie
movieDecoder =
    succeed Movie
        |> required "display_title" string
        |> required "headline" string
        |> required "summary_short" string
        |> required "publication_date" string
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

        LoadMovieFeed (Err error) ->
            ( { model | error = Just error }, Cmd.none )

        LoadMoreMovies (Ok feed) ->
            ( { model | feed = Just feed }, Cmd.none )

        LoadMoreMovies (Err error) ->
            ( { model | error = Just error }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [] [ viewCheckMovieFeed model ]


viewCheckMovieFeed : Model -> Html Msg
viewCheckMovieFeed model =
    case model.error of
        Just err ->
            div [] [ text (errorMessage err) ]

        Nothing ->
            viewMovieFeed model.feed


viewMovieFeed : Maybe Feed -> Html Msg
viewMovieFeed maybeFeed =
    case maybeFeed of
        Just feed ->
            div [] (List.map viewMovieDetail feed.results)

        Nothing ->
            div [] [ text "Loading movies..." ]


viewMovieDetail : Movie -> Html Msg
viewMovieDetail movie =
    div [ class "movie" ]
        [ ul []
            [ li [] [ text movie.displayTitle ]
            , li [] [ text movie.headline ]
            ]
        ]


errorMessage : Http.Error -> String
errorMessage error =
    case error of
        Http.BadBody _ ->
            "Sorry, something went wrong. Please try again later."

        _ ->
            "Sorry, we couldn't load your feed right now. Try again later"



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
