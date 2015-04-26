(** Type to represent effects, where ['a] is the return type of
    the effect. *)
type 'a effect = ..

(** [perform e] performs an effect [e].

    @raises Unhandled if there is no active handler. *)
val perform : 'a effect -> 'a

(** Type to represent single-shot continuations waiting for an
    ['a], which will return a [b']. *)
type ('a, 'b) continuation

(** Type to represent effect handlers which return ['b]. *)
type ('b,'c) handler =
   { effect: 'a. 'a effect -> ('a, 'c) continuation -> 'c;
     exn: exn -> 'c;
     return: 'b -> 'c; }

(** [handle h f] runs the [f] within an effect handler [h]. *)
val handle: ('b, 'c) handler -> ('a -> 'b) -> 'a -> 'c

(** [continue k x] resumes the continuation [k] by passing [x] to [k].

    @raise Invalid_argument if the continuation has already been
    resumed. *)
val continue: ('a, 'b) continuation -> 'a -> 'b

(** [discontinue k e] resumes the continuation [k] by raising the
    exception [e] in [k].

    @raise Invalid_argument if the continuation has already been
    resumed. *)
val discontinue: ('a, 'b) continuation -> exn -> 'b

(** [delegate e k] is semantically equivalent to:

    {[
      match perform e with
      | v -> continue k v
      | exception e -> discontinue k e
    ]}

    but it can be implemented directly more efficiently and is a
    very common case: it is what you should do with effects that
    you don't handle. *)
val delegate: 'a effect -> ('a, 'b) continuation -> 'b
