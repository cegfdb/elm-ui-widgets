module Widget.Snackbar exposing
    ( Model, init, current, timePassed
    , insert, insertFor, dismiss
    )

{-| A [snackbar](https://material.io/components/snackbars/) shows notification, one at a time.


# Basics

@docs Model, init, current, timePassed


# Operations

@docs insert, insertFor, dismiss

-}

import Queue exposing (Queue)


{-| A snackbar has a queue of Notifications, each with the amount of ms the message should be displayed
-}
type alias Model a =
    { queue : Queue ( a, Int )
    , current : Maybe ( a, Int )
    }


{-| Inital state
-}
init : Model a
init =
    { queue = Queue.empty
    , current = Nothing
    }


{-| Insert a message that will last for 10 seconds.
-}
insert : a -> Model a -> Model a
insert =
    insertFor 10000


{-| Insert a message for a specific amount of milli seconds.
-}
insertFor : Int -> a -> Model a -> Model a
insertFor removeIn a model =
    case model.current of
        Nothing ->
            { model | current = Just ( a, removeIn ) }

        Just _ ->
            { model | queue = model.queue |> Queue.enqueue ( a, removeIn ) }


{-| Dismiss the current message.
-}
dismiss : Model a -> Model a
dismiss model =
    { model | current = Nothing }


{-| Updates the model. This functions should be called regularly.
The first argument is the milli seconds that passed since the last time the function was called.
-}
timePassed : Int -> Model a -> Model a
timePassed ms model =
    case model.current of
        Nothing ->
            let
                ( c, queue ) =
                    model.queue |> Queue.dequeue
            in
            { model
                | current = c
                , queue = queue
            }

        Just ( _, removeIn ) ->
            if removeIn <= ms then
                model |> dismiss

            else
                { model | current = model.current |> Maybe.map (Tuple.mapSecond ((+) -ms)) }


{-| Returns the current element.
-}
current : Model a -> Maybe a
current model =
    model.current |> Maybe.map Tuple.first