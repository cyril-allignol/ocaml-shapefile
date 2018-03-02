(* finally and with_dispose taken from Batteries *)
let finally = fun handler f x ->
  let res = try f x with exn -> handler (); raise exn in
  handler ();
  res

let with_dispose = fun dispose f x -> finally (fun () -> dispose x) f x

let parse = fun ch ->
  let lexbuf = Lexing.from_channel ch in
  try Prj_parser.prj Prj_lexer.token lexbuf
  with exn -> begin
    let tok = Lexing.lexeme lexbuf in
    Printf.eprintf "\nError while reading token:\"%s\"\n%!" tok;
    raise exn end

let read = fun file ->
  let ch = open_in file in
  with_dispose close_in parse ch
