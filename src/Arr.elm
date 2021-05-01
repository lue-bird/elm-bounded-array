module Arr exposing
    ( Arr
    , fromArray, repeat, nats, random
    , empty, from1, from2, from3, from4, from10, from11, from12, from13, from14, from15, from16, from5, from6, from7, from8, from9
    , length, at
    , take, drop
    , map, fold, toArray, map2, map3, map4, foldWith, reverse
    , replaceAt
    , lowerMinLength
    , restoreMaxLength, restoreLength
    , serialize
    )

{-| An `Arr` describes an array where you know more about the amount of elements.

    Array.empty |> Array.get 0
    --> Nothing

    Arr.empty |> Arr.at nat0 FirstToLast
    --> compile time error

Is this any useful? Let's look at an example:

> 0 to 100 joined by a space

    joinBy between =
        \before after -> before ++ between ++ after

    let
        intStringsAfter =
            Array.fromList (List.range 1 100)
                String.fromInt
    in
    Array.foldl (joinBy " ") "0" intStringsAfter
    --> "0 1 2 3 4 5 ..."

    Arr.nats nat100
        |> Arr.map (val >> String.fromInt)
        |> Arr.foldWith FirstToLast (joinBy " ")
    --> "0 1 2 3 4 5 ..."

The `Array` version just seems hacky and is less readable. `Arr` simply knows more about the length at compile time, so you can e.g. call `foldWith` without a worry.

@docs Arr


## create

@docs fromArray, repeat, nats, random


### exact

@docs empty, from1, from2, from3, from4, from10, from11, from12, from13, from14, from15, from16, from5, from6, from7, from8, from9


## scan

@docs length, at


## part

@docs take, drop


## transform

@docs map, fold, toArray, map2, map3, map4, foldWith, reverse


### modify

@docs replaceAt


## drop information

@docs lowerMinLength


## restore information

@docs restoreMaxLength, restoreLength


## extra

@docs serialize

-}

import Arguments exposing (..)
import Array exposing (Array)
import Array.LinearDirection as Array
import Internal.Arr as Internal
import LinearDirection exposing (LinearDirection(..))
import NNat exposing (..)
import NNats exposing (nat0)
import Nat exposing (In, Is, N, Nat, Only, To, ValueIn, ValueMin, ValueN)
import Random
import Serialize
import TypeNats exposing (..)
import Typed exposing (Checked, Internal, Typed)


{-| An `Arr` describes an array where you know more about the amount of elements.


## value / return types

  - amount >= 5

```
Arr (ValueMin Nat5) ...
```

  - 2 <= amount <= 12

```
Arr (ValueIn Nat2 Nat12) ...
```

  - = 4

```
Arr (ValueOnly Nat4) ...
```

  - the exact amount 3, also described as the difference between 2 numbers

```
Arr
    (ValueN Nat3
        (Nat3Plus more)
        (Is a To (Nat3Plus a))
        (Is b To (Nat3Plus b))
    )
```


## function argument types

  - amount >= 4

```
Arr (In (Nat4Plus minMinus4) max maybeN) ...
```

  - 4 <= amount <= 15

```
Arr (In (Nat4Plus minMinus4) Nat15 maybeN) ...
```

  - = 15

```
Arr (Only Nat15) ...
```

  - any amount

```
Arr range ...
```

-}
type alias Arr length element =
    Typed
        Checked
        Internal.ArrTag
        Internal
        (Internal.Content length element)


{-| Convert the `Arr` to an `Array`.
Just do this in the end.
Try to keep extra information as long as you can.

    Arr.nats nat5
        |> Arr.map val
        |> Arr.toArray
    --> Array.fromList [ 0, 1, 2, 3, 4 ]

-}
toArray : Arr length element -> Array element
toArray =
    Internal.toArray



-- ## create


{-| An `Arr` with a given amount of same elements.

    Arr.repeat nat4 'L'
    --> Arr.from4 'L' 'L' 'L' 'L'
    --> : Arr (ValueN Nat4 ...) Char


    Arr.repeat atLeast3 'L'
    --> : Arr (ValueMin Nat3) Char

-}
repeat :
    Nat length
    -> element
    -> Arr length element
repeat amount element =
    Internal.repeat amount element


{-| Create an `Arr` from an `Array`. As every `Array` has `>= 0` elements:

    Arr.fromArray arrayFromSomewhere
    --> : Arr (ValueMin Nat0)

    Arr.fromArray
        (Array.fromList [ 0, 1, 2, 3, 4, 5, 6 ])
    --> big no

    Arr.from7 0 1 2 3 4 5 6
    --> ok

    Arr.nats nat7
    --> big yes

Tell the compiler if you know the amount of elements. Make sure the it knows as much as you!

-}
fromArray : Array element -> Arr (ValueMin Nat0) element
fromArray =
    Internal.fromArray


{-| No elements.

    Arr.empty
    --> : Arr (ValueN Nat0 ...) element
        |> NArr.push ":)"
    --> : Arr (ValueN Nat1 ...) String

-}
empty : Arr (ValueN Nat0 atLeast0 (Is a To a) (Is b To b)) element
empty =
    Internal.empty


{-| Create an `Arr (ValueN Nat1 ...)` from exactly 1 element in this order.
-}
from1 :
    element
    -> Arr (ValueN Nat1 (Nat1Plus more) (Is a To (Nat1Plus a)) (Is b To (Nat1Plus b))) element
from1 =
    \a -> empty |> push a


{-| Create an `Arr (ValueN Nat2 ...)` from exactly 2 element in this order.
-}
from2 :
    element
    -> element
    -> Arr (ValueN Nat2 (Nat2Plus more) (Is a To (Nat2Plus a)) (Is b To (Nat2Plus b))) element
from2 =
    apply1 from1 (\init -> \last -> init |> push last)


{-| Create an `Arr (ValueN Nat3 ...)` from exactly 3 element in this order.
-}
from3 :
    element
    -> element
    -> element
    -> Arr (ValueN Nat3 (Nat3Plus more) (Is a To (Nat3Plus a)) (Is b To (Nat3Plus b))) element
from3 =
    apply2 from2 (\init -> \last -> init |> push last)


{-| Create an `Arr (ValueN Nat4 ...)` from exactly 4 element in this order.
-}
from4 :
    element
    -> element
    -> element
    -> element
    -> Arr (ValueN Nat4 (Nat4Plus more) (Is a To (Nat4Plus a)) (Is b To (Nat4Plus b))) element
from4 =
    apply3 from3 (\init -> \last -> init |> push last)


{-| Create an `Arr (ValueN Nat5 ...)` from exactly 5 element in this order.
-}
from5 :
    element
    -> element
    -> element
    -> element
    -> element
    -> Arr (ValueN Nat5 (Nat5Plus more) (Is a To (Nat5Plus a)) (Is b To (Nat5Plus b))) element
from5 =
    apply4 from4 (\init -> \last -> init |> push last)


{-| Create an `Arr (ValueN Nat6 ...)` from exactly 6 element in this order.
-}
from6 :
    element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> Arr (ValueN Nat6 (Nat6Plus more) (Is a To (Nat6Plus a)) (Is b To (Nat6Plus b))) element
from6 =
    apply5 from5 (\init -> \last -> init |> push last)


{-| Create an `Arr (ValueN Nat7 ...)` from exactly 7 element in this order.
-}
from7 :
    element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> Arr (ValueN Nat7 (Nat7Plus more) (Is a To (Nat7Plus a)) (Is b To (Nat7Plus b))) element
from7 =
    apply6 from6 (\init -> \last -> init |> push last)


{-| Create an `Arr (ValueN Nat8 ...)` from exactly 8 element in this order.
-}
from8 :
    element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> Arr (ValueN Nat8 (Nat8Plus more) (Is a To (Nat8Plus a)) (Is b To (Nat8Plus b))) element
from8 =
    apply7 from7 (\init -> \last -> init |> push last)


{-| Create an `Arr (ValueN Nat9 ...)` from exactly 9 element in this order.
-}
from9 :
    element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> Arr (ValueN Nat9 (Nat9Plus more) (Is a To (Nat9Plus a)) (Is b To (Nat9Plus b))) element
from9 =
    apply8 from8 (\init -> \last -> init |> push last)


{-| Create an `Arr (ValueN Nat10 ...)` from exactly 10 element in this order.
-}
from10 :
    element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> Arr (ValueN Nat10 (Nat10Plus more) (Is a To (Nat10Plus a)) (Is b To (Nat10Plus b))) element
from10 =
    apply9 from9 (\init -> \last -> init |> push last)


{-| Create an `Arr (ValueN Nat11 ...)` from exactly 11 element in this order.
-}
from11 :
    element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> Arr (ValueN Nat11 (Nat11Plus more) (Is a To (Nat11Plus a)) (Is b To (Nat11Plus b))) element
from11 =
    apply10 from10 (\init -> \last -> init |> push last)


{-| Create an `Arr (ValueN Nat12 ...)` from exactly 12 element in this order.
-}
from12 :
    element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> Arr (ValueN Nat12 (Nat12Plus more) (Is a To (Nat12Plus a)) (Is b To (Nat12Plus b))) element
from12 =
    apply11 from11 (\init -> \last -> init |> push last)


{-| Create an `Arr (ValueN Nat13 ...)` from exactly 13 element in this order.
-}
from13 :
    element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> Arr (ValueN Nat13 (Nat13Plus more) (Is a To (Nat13Plus a)) (Is b To (Nat13Plus b))) element
from13 =
    apply12 from12 (\init -> \last -> init |> push last)


{-| Create an `Arr (ValueN Nat14 ...)` from exactly 14 element in this order.
-}
from14 :
    element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> Arr (ValueN Nat14 (Nat14Plus more) (Is a To (Nat14Plus a)) (Is b To (Nat14Plus b))) element
from14 =
    apply13 from13 (\init -> \last -> init |> push last)


{-| Create an `Arr (ValueN Nat15 ...)` from exactly 15 element in this order.
-}
from15 :
    element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> Arr (ValueN Nat15 (Nat15Plus more) (Is a To (Nat15Plus a)) (Is b To (Nat15Plus b))) element
from15 =
    apply14 from14 (\init -> \last -> init |> push last)


{-| Create an `Arr (ValueN Nat16 ...)` from exactly 16 element in this order.
-}
from16 :
    element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> element
    -> Arr (ValueN Nat16 (Nat16Plus more) (Is a To (Nat16Plus a)) (Is b To (Nat16Plus b))) element
from16 =
    apply15 from15 (\init -> \last -> init |> push last)



-- ## modify


push :
    element
    -> Arr (ValueN n atLeastN (Is a To nPlusA) (Is b To nPlusB)) element
    ->
        Arr
            (ValueN
                (Nat1Plus n)
                (Nat1Plus atLeastN)
                (Is a To (Nat1Plus nPlusA))
                (Is b To (Nat1Plus nPlusB))
            )
            element
push element =
    Internal.nPush element


{-| Set the element at an index in a direction.

    Arr.from3 "I" "am" "ok"
        |> Arr.replaceAt nat2 FirstToLast "confusion"
    --> Arr.from3 "I" "am" "confusion"

    Arr.from3 "I" "am" "ok"
        |> Arr.replaceAt nat1 LastToFirst "feel"
    --> Arr.from3 "I" "feel" "ok"

-}
replaceAt :
    Nat (In indexMin minLengthMinus1 indexMaybeN)
    -> LinearDirection
    -> element
    -> Arr (In (Nat1Plus minLengthMinus1) max maybeN) element
    -> Arr (In (Nat1Plus minLengthMinus1) max maybeN) element
replaceAt index direction replacingElement =
    Internal.replaceAt index direction replacingElement



-- ## part


{-| This works for both

    Arr.from8 0 1 2 3 4 5 6 7
        |> Arr.take nat3 nat3 LastToFirst
    --> Arr.from3 5 6 7

    Arr.from8 0 1 2 3 4 5 6 7
        |> Arr.take between3To7 nat7 FirstToLast
    --> : Arr (ValueIn Nat3 Nat7) ...

-}
take :
    Nat (In minTaken maxTaken takenMaybeN)
    -> Nat (N maxTaken (Is a To atLeastMaxTaken) (Is maxTakenToMin To min))
    -> LinearDirection
    -> Arr (In min max maybeN) element
    -> Arr (In minTaken atLeastMaxTaken takenMaybeN) element
take takenAmount maxAmount direction =
    Internal.take takenAmount maxAmount direction


{-| After a certain number of elements from one side.

    with6To10Elements
        |> Arr.drop nat2 LastToFirst
    --> : Arr (In Nat4 (Nat10Plus a)) ...

Use `take` `LastToFirst` if you know the exact amount of elements.

-}
drop :
    Nat (N dropped (Is minTaken To min) (Is maxTaken To max))
    -> LinearDirection
    -> Arr (In min max maybeN) element
    -> Arr (ValueIn minTaken maxTaken) element
drop droppedAmount direction =
    Internal.drop droppedAmount direction



-- ## transform


{-| Change every element.

    aToZ =
        Arr.nats nat26
            |> Arr.map
                ((+) ('a' |> Char.toCode)
                    >> Char.fromCode
                )

-}
map :
    (aElement -> bElement)
    -> Arr length aElement
    -> Arr length bElement
map alter =
    Internal.map alter


{-| Combine the elements of 2 `Arr`s to a new element.
If one list is longer, the extra elements are dropped.

    teamLifes aBoard bBoard =
        Arr.map2 (\a b -> a.lifes + b.lifes)
            aBoard
            bBoard

-}
map2 :
    (a -> b -> combined)
    -> Arr length a
    -> Arr length b
    -> Arr length combined
map2 combine aArr bArr =
    Internal.map2 combine aArr bArr


{-| Works like [map2](Arr#map2).
-}
map3 :
    (a -> b -> c -> combinedElement)
    -> Arr length a
    -> Arr length b
    -> Arr length c
    -> Arr length combinedElement
map3 combine aArr bArr cArr =
    map2 (\f c -> f c)
        (map2 combine aArr bArr)
        cArr


{-| Works like [map2](Arr#map2).
-}
map4 :
    (a -> b -> c -> d -> combinedElement)
    -> Arr length a
    -> Arr length b
    -> Arr length c
    -> Arr length d
    -> Arr length combinedElement
map4 combine aArr bArr cArr dArr =
    map2 (\f c -> f c)
        (map3 combine aArr bArr cArr)
        dArr


{-| Reduce an `Arr` in a [direction](https://package.elm-lang.org/packages/indique/elm-linear-direction/latest/).

    Arr.from5 "l" "i" "v" "e"
        |> Arr.fold FirstToLast (++) ""
    --> "live"

    Arr.from5 "l" "i" "v" "e"
        |> Arr.fold LastToFirst (++) ""
    --> "evil"

-}
fold :
    LinearDirection
    -> (element -> result -> result)
    -> result
    -> Arr (In min max maybeExact) element
    -> result
fold direction reduce initial =
    toArray >> Array.fold direction reduce initial


{-| A fold where the initial result is the first value.

    Arr.foldWith FirstToLast maximum
        (Arr.from3 234 345 543)
    --> 543

-}
foldWith :
    LinearDirection
    -> (element -> element -> element)
    -> Arr (In (Nat1Plus minMinus1) max maybeN) element
    -> element
foldWith direction reduce =
    \inArr ->
        Array.fold direction
            reduce
            (at nat0 direction inArr)
            (Array.removeAt 0
                (LinearDirection.opposite direction)
                (inArr |> toArray)
            )



-- ## scan


{-| The amount of elements.
-}
length : Arr length element -> Nat length
length =
    Internal.length


{-| Element at a valid position.

    Arr.from3 1 2 3
        |> Arr.at nat1
    --> 2

-}
at :
    Nat (In indexMin minMinus1 indexMaybeN)
    -> LinearDirection
    -> Arr (In (Nat1Plus minMinus1) max maybeN) element
    -> element
at index direction =
    Internal.at index direction



-- ## extra


{-| Flip the order of the elements.

    Arr.from5 "l" "i" "v" "e"
        |> Arr.reverse
    --> Arr.from5 "e" "v" "i" "l"

-}
reverse : Arr length element -> Arr length element
reverse =
    Internal.reverse



-- ## drop information


{-| Use a lower minimum length in the type.

    [ atLeast3Elements
    , atLeast4Elements
    ]

Elm complains:

> But all the previous elements in the list are
> `Arr (ValueMin Nat3) ...`

    [ atLeast3Elements
    , atLeast4Elements
        |> Arr.lowerMinLength nat3
    ]

-}
lowerMinLength :
    Nat (In lowerMin min lowerMaybeN)
    -> Arr (In min max maybeN) element
    -> Arr (ValueIn lowerMin max) element
lowerMinLength =
    Internal.lowerMinLength



-- ## restore information


{-| Make an `Arr` with a fixed maximum length fit into functions with require a higher maximum length.

While designing argument annotations as general as possible:

    atMost18Elements : Arr (In min Nat18 maybeN) ...

The argument in `atMost18Elements` should also fit in `atMost19Elements`.

    atMost19Elements theArgument
    --> error :(

    atMost19Elements
        (theArgument |> Arr.restoreMaxLength nat18)
    --> works

-}
restoreMaxLength :
    Nat (N max (Is a To atLeastMax) x)
    -> Arr (In min max maybeN) element
    -> Arr (In min atLeastMax maybeN) element
restoreMaxLength maximumLength =
    Internal.restoreMaxLength maximumLength


{-| Transform a potential `ValueOnly` `Arr` to a `ValueN`.

    append10s :
        Arr (Only Nat10 aMaybeN) element
        -> Arr (Only Nat10 bMaybeN) element
        -> Arr (ValueN Nat20 (Nat20Plus a) ...)
    append10s a10Elements b10Elements =
        a10Elements
            |> InArr.extend nat10 nat10 b10Elements
            |> Arr.restoreLength nat20

-}
restoreLength :
    Nat (ValueN n atLeastN aDifference bDifference)
    -> Arr (Only n maybeN) element
    -> Arr (ValueN n atLeastN aDifference bDifference) element
restoreLength length_ =
    Internal.restoreLength length_



-- ## create


{-| Increasing natural numbers. In the end, there are `length` numbers.

    Arr.nats nat10
    --> : Arr
    -->     (ValueN Nat10 ...)
    -->     (Nat (ValueIn Nat0 (Nat9Plus a)))

    from first length_ =
        Arr.nats length_
            |> Arr.map (InNat.add first)

-}
nats :
    Nat
        (In
            (Nat1Plus minLengthMinus1)
            (Nat1Plus maxLengthMinus1)
            lengthMaybeN
        )
    ->
        Arr
            (In
                (Nat1Plus minLengthMinus1)
                (Nat1Plus maxLengthMinus1)
                lengthMaybeN
            )
            (Nat (ValueIn Nat0 maxLengthMinus1))
nats length_ =
    Internal.nats length_


{-| Generate a given `amount` of elements and put them in an `Arr`.
-}
random :
    Nat length
    -> Random.Generator element
    -> Random.Generator (Arr length element)
random amount generateElement =
    Internal.random amount generateElement


{-| A [`Codec`](https://package.elm-lang.org/packages/MartinSStewart/elm-serialize/latest/) to serialize `Arr`s with a specific amount of elements.

    import Serialize


    -- we can't start if we have no worlds to choose from!
    serializeGameRow :
        Serialize.Codec
            String
            (Arr (ValueN Nat10 ...) GameField)
    serializeGameRow =
        Arr.serialize nat10 serializeGameField

    encode : Arr (Only Nat10 maybeN) GameField -> Bytes
    encode =
        Arr.restoreLength nat10
            >> Serialize.encodeToBytes serializeGameRow

    decode :
        Bytes
        ->
            Result
                (Serialize.Error String)
                (Arr (ValueN Nat10 ...) GameField)
    decode =
        Serialize.decodeFromBytes serializeGameRow

-}
serialize :
    Nat length
    -> Serialize.Codec String element
    -> Serialize.Codec String (Arr length element)
serialize length_ serializeElement =
    Internal.serialize length_ serializeElement
