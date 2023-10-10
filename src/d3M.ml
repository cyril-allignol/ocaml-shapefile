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

let dim = 4

type point = { x: float; y: float; z: float; m: float }

let a2p = function
  | [| x; y; z; m |] -> { x; y; z; m }
  | _a -> invalid_arg "a2p"

type bbox = { xmin: float; xmax: float; ymin: float; ymax: float;
	      zmin: float; zmax: float; mmin: float; mmax: float }

let print_bbox { xmin; xmax; ymin; ymax; zmin; zmax; mmin; mmax } =
  Printf.printf "xmin = %f, xmax = %f\n" xmin xmax;
  Printf.printf "ymin = %f, ymax = %f\n" ymin ymax;
  Printf.printf "zmin = %f, zmax = %f\n" zmin zmax;
  Printf.printf "mmin = %f, mmax = %f\n" mmin mmax


let a2b = function
  | [| xmin; ymin; xmax; ymax; zmin; zmax; mmin; mmax|] -> { xmin; ymin; zmin; mmin; xmax; ymax; zmax; mmax }
  | _a -> invalid_arg "a2b"
