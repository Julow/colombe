type encoder =
  { payload : Bytes.t
  ; mutable pos : int }

type error = No_enough_space

let pp_error ppf No_enough_space = Fmt.string ppf "No_enough_space"

type state =
  | Write of { buffer : Bytes.t
              ; off : int
              ; len : int
              ; continue : int -> state }
  | Error of error
  | Ok

let io_buffer_size = 65536

let encoder () =
  { payload= Bytes.create io_buffer_size
  ; pos= 0 }

exception Leave of error

let leave_with (_ : encoder) error =
  raise (Leave error)

let safe k encoder : state =
  try k encoder with Leave error -> Error error

let flush k0 encoder =
  if encoder.pos > 0
  then
    let rec k1 n =
      if n < encoder.pos
      then Write { buffer= encoder.payload
                  ; off= n
                  ; len= encoder.pos - n
                  ; continue= (fun m -> k1 (n + m)) }
      else ( encoder.pos <- 0 ; k0 encoder ) in
    k1 0
  else k0 encoder

let write s encoder =
  let max = Bytes.length encoder.payload in
  let go j l encoder =
    let rem = max - encoder.pos in
    let len = if l > rem then rem else l in
    Bytes.blit_string s j encoder.payload encoder.pos len ;
    encoder.pos <- encoder.pos + len ;
    if len < l then leave_with encoder No_enough_space in
  (* XXX(dinosaure): should never appear, but avoid continuation allocation. *)
  go 0 (String.length s) encoder

