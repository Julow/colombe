open Lwt

let tls_wrap server =
  Fmt.pf Fmt.stdout "Initializing TLS connection\n%!";
  X509_lwt.authenticator `No_authentication_I'M_STUPID
  >>= fun authenticator ->
  let config = Tls.Config.(client ~authenticator ~ciphers:Ciphers.supported ()) in
  Tls_lwt.connect_ext config server

let stream_of_list = Client.stream_of_list
let stream_concat = Client.stream_concat

let send_mail
    ~server
    ~auth
    ~from
    ~to_
    ?headers
    subject body =
  tls_wrap server >>= fun (ic, oc) ->
  let ic () = Lwt_io.read_line ic in
  let oc s = Lwt_io.write oc s in
  Client.send_mail ~auth ~from ~to_ ?headers subject body
    ic oc
