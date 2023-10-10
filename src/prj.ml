(* Copyright 2018 Cyril Allignol
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License. *)

let parse ch =
  let lexbuf = Lexing.from_channel ch in
  try Prj_parser.prj Prj_lexer.token lexbuf
  with exn -> begin
    let tok = Lexing.lexeme lexbuf in
    Printf.eprintf "\nError while reading token:\"%s\"\n%!" tok;
    raise exn end

let read file =
  let chan = open_in file in
  Fun.protect
    ~finally:(fun () -> close_in chan)
    (fun () -> parse chan)
