open Lwt

module IO =
struct

  type ic = Lwt_io.input_channel
  type oc = Lwt_io.output_channel

  let tls_wrap server =
    Fmt.pf Fmt.stdout "Initializing TLS connection\n%!";
    X509_lwt.authenticator `No_authentication_I'M_STUPID
    >>= fun authenticator ->
    let config = Tls.Config.(client ~authenticator ~ciphers:Ciphers.supported ()) in
    Tls_lwt.connect_ext config server

  let read_line = Lwt_io.read_line
  let write = Lwt_io.write

end

include Client.Make (IO)
