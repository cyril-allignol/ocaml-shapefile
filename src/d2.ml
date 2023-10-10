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

let dim = 2

type point = { x: float; y: float }

let a2p = function
  | [| x; y|] -> { x; y }
  | _a -> invalid_arg "a2p"

type bbox = { xmin: float; xmax: float; ymin: float; ymax: float }

let a2b = function
  | [| xmin; ymin; xmax; ymax|] -> { xmin; xmax; ymin; ymax }
  | _a -> invalid_arg "a2b"

let print_bbox { xmin; xmax; ymin; ymax } =
  Printf.printf "xmin = %f, xmax = %f\n" xmin xmax;
  Printf.printf "ymin = %f, ymax = %f\n" ymin ymax
