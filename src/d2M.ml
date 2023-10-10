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

let dim = 3

type point = { x: float; y: float; m: float }

let a2p = function
  | [| x; y; m|] -> { x; y; m }
  | _a -> invalid_arg "a2p"

type bbox = { xmin: float; xmax: float; ymin: float; ymax: float;
	      mmin: float; mmax: float }

let a2b = function
  | [| xmin; ymin; mmin; xmax; ymax; mmax|] -> { xmin; xmax; ymin; ymax; mmin; mmax }
  | _a -> invalid_arg "a2b"

let print_bbox { xmin; xmax; ymin; ymax; mmin; mmax } =
  Printf.printf "xmin = %f, xmax = %f\n" xmin xmax;
  Printf.printf "ymin = %f, ymax = %f\n" ymin ymax;
  Printf.printf "mmin = %f, mmax = %f\n" mmin mmax
