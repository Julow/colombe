open Colombe

type status = Beginning | Established | Connected | Auth1 | Auth2 | Auth3 | Mail | Rcpt | Data | Data_feed | End

type context = {decoder: Reply.Decoder.decoder; encoder: Request.Encoder.encoder; status: status}

val run:
  context ->
  [< `Auth1
  | `Auth2
  | `Auth3
  | `Data
  | `Data_feed of string list
  | `Establishment
  | `Hello of Domain.t
  | `Mail of Reverse_path.t * (string * string option) list
  | `Quit
  | `Recipient of Forward_path.t * (string * string option) list ] ->
  ([> `End of status
    | `Error of string
    | `Read of bytes * int * int * (int -> 'a)
    | `Write of bytes * int * int * (int -> 'a) ]
  as 'a)