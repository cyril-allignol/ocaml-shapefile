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

let pp_opt pp_v fmt o =
  Format.pp_print_option (fun fmt v -> Format.fprintf fmt ", %a" pp_v v) fmt o

let pp_list pp_v fmt l =
  Format.pp_print_list ~pp_sep:(fun fmt () -> Format.fprintf fmt ", ") pp_v fmt l

module Parameter = struct
  type t = { name: string; value: float }
  let pp fmt { name; value } =
    Format.fprintf fmt {|PARAMETER["%s", %f]"|} name value
end

module MT = struct
  type t =
    | Param of string * Parameter.t list
    | Concat of t list
    | Inverse of t
    | Passthrough of int * t

  let rec pp fmt = function
    | Param (name, ps) ->
	Format.fprintf fmt {|PARAM_MT["%s"%a]|} name (pp_list Parameter.pp) ps
    | Concat (mt :: mts) ->
	Format.fprintf fmt "CONCAT_MT[%a%a]" pp mt (pp_list pp) mts
    | Concat _ -> invalid_arg "Prj_syntax.MT"
    | Inverse mt -> Format.fprintf fmt "INVERSE_MT[%a]" pp mt
    | Passthrough (i, mt) ->
	Format.fprintf fmt "PASSTHROUGH_MT[%d, %a]" i pp mt

end

module Authority = struct
  type t = { name: string; code: string }
  let pp fmt { name; code } =
    Format.fprintf fmt {|AUTHORITY["%s", "%s"]|} name code
end

module Axis = struct
  type direction = North | South | East | West | Up | Down | Other
  type t = { name: string; direction: direction }
  let pp_dir fmt = function
    | North -> Format.pp_print_string fmt "NORTH"
    | South -> Format.pp_print_string fmt "SOUTH"
    | East -> Format.pp_print_string fmt "EAST"
    | West -> Format.pp_print_string fmt "WEST"
    | Up -> Format.pp_print_string fmt "UP"
    | Down -> Format.pp_print_string fmt "DOWN"
    | Other -> Format.pp_print_string fmt "OTHER"
  let pp fmt { name; direction } =
  Format.fprintf fmt {|AXIS["%s", %a]|} name pp_dir direction

  let geographic_default =
    { name = "Lon"; direction = East }, { name = "Lat"; direction = North }
  let projected_default =
    { name = "X"; direction = East }, { name = "Y"; direction = North }
  let geocentric_default =
    { name = "X"; direction = Other },
    { name = "Y"; direction = East }, { name = "Z"; direction = North }
end

module Unit = struct
  type t = { name: string; cf: float; authority: Authority.t option }
  let pp fmt { name; cf; authority } =
    Format.fprintf fmt {|UNIT["%s", %f%a]|} name cf
      (pp_opt Authority.pp) authority
end

module Primem = struct
  type t = { name: string; longitude: float; authority: Authority.t option }
  let pp fmt { name; longitude; authority } =
    Format.fprintf fmt {|PRIMEM["%s", %f%a]|} name longitude
      (pp_opt Authority.pp) authority
end

module ToWGS84 = struct
  type t = { dx: float; dy: float; dz: float;
	     ex: float; ey: float; ez: float;
	     ppm: float }
  let pp fmt { dx; dy; dz; ex; ey; ez; ppm } =
    Format.fprintf fmt "TOWGS84[%f, %f, %f, %f, %f, %f, %f]"
      dx dy dz ex ey ez ppm
end

module Spheroid = struct
  type t = { name: string; a: float; f: float; authority: Authority.t option }
  let pp fmt { name; a; f; authority } =
    Format.fprintf fmt {|SPHEROID["%s", %f, %f%a]|}
      name a f (pp_opt Authority.pp) authority
end

module Datum = struct
  type t = { name: string; spheroid: Spheroid.t;
	     toWGS84: ToWGS84.t option; authority: Authority.t option }
  let pp fmt { name; spheroid; toWGS84; authority } =
    Format.fprintf fmt {|DATUM["%s", %a%a%a]|} name Spheroid.pp spheroid
      (pp_opt ToWGS84.pp) toWGS84
      (pp_opt Authority.pp) authority
end

module Vert_datum = struct
  type t = { name: string; datum_type: float; authority: Authority.t option }
  let pp fmt { name; datum_type; authority } =
    Format.fprintf fmt {|VERT_DATUM["%s", %f%a]|}
      name datum_type (pp_opt Authority.pp) authority
end

module Local_datum = struct
  type t = { name: string; datum_type: float; authority: Authority.t option }
  let pp fmt { name; datum_type; authority } =
    Format.fprintf fmt {|LOCAL_DATUM["%s", %f%a]|}
      name datum_type (pp_opt Authority.pp) authority
end

module Projection = struct
  type t = { name: string; authority: Authority.t option }
  let pp fmt { name; authority } =
    Format.fprintf fmt {|PROJECTION["%s"%a]|}
      name (pp_opt Authority.pp) authority
end

module GeogCS = struct
  type t = { name: string; datum: Datum.t; prime_meridian: Primem.t;
	     angular_unit: Unit.t; axes: Axis.t * Axis.t;
	     authority: Authority.t option }
  let pp fmt { axes; name; prime_meridian; angular_unit; authority; datum } =
    let lon_axis, lat_axis = axes in
    Format.fprintf fmt {|GEOGCS["%s", %a, %a, %a, %a, %a%a]|}
      name Datum.pp datum Primem.pp prime_meridian
      Unit.pp angular_unit Axis.pp lon_axis Axis.pp lat_axis
      (pp_opt Authority.pp) authority
end

module ProjCS = struct
  type t = { name: string; geogcs: GeogCS.t; projection: Projection.t;
	     params: Parameter.t list; linear_unit: Unit.t;
	     axes: Axis.t * Axis.t; authority: Authority.t option }
  let pp fmt { axes; name; geogcs; projection; params; linear_unit; authority } =
    let x_axis, y_axis = axes in
    Format.fprintf fmt {|PROJCS["%s", %a, %a, %a, %a, %a, %a%a]|}
      name GeogCS.pp geogcs Projection.pp projection
      (pp_list Parameter.pp) params Unit.pp linear_unit
      Axis.pp x_axis Axis.pp y_axis
      (pp_opt Authority.pp) authority
end

module GeocCS = struct
  type t = { name: string; datum: Datum.t; prime_meridian: Primem.t;
	     linear_unit: Unit.t; axes: Axis.t * Axis.t * Axis.t;
	     authority: Authority.t option }
  let pp fmt { name; datum; prime_meridian; linear_unit; axes; authority } =
    let x_axis, y_axis, z_axis = axes in
    Format.fprintf fmt {|GEOCCS["%s", %a, %a, %a, %a, %a, %a%a]|}
      name Datum.pp datum Primem.pp prime_meridian
      Unit.pp linear_unit
      Axis.pp x_axis Axis.pp y_axis Axis.pp z_axis
      (pp_opt Authority.pp) authority
end

module VertCS = struct
  type t = { name: string; datum: Vert_datum.t; linear_unit: Unit.t;
	     axis: Axis.t; authority: Authority.t option }
  let pp fmt { name; datum; linear_unit; authority; axis } =
    Format.fprintf fmt {|VERT_CS["%s", %a, %a, %a%a]|}
      name Vert_datum.pp datum Unit.pp linear_unit
      Axis.pp axis (pp_opt Authority.pp) authority
end

module LocalCS = struct
  type t = { name: string; datum: Local_datum.t; unit: Unit.t;
	     axes: Axis.t list; authority: Authority.t option }
  let pp fmt { name; datum; unit; axes; authority } =
    Format.fprintf fmt {|LOCAL_CS["%s", %a, %a, %a%a]|}
      name Local_datum.pp datum Unit.pp unit
      (pp_list Axis.pp) axes
      (pp_opt Authority.pp) authority
end

module CS = struct
  type t =
    | Geographic of GeogCS.t
    | Projected of ProjCS.t
    | Geocentric of GeocCS.t
    | Vert of VertCS.t
    | Compd of string * t * t * Authority.t option
    | Fitted of string * MT.t * t
    | Local of LocalCS.t

  let rec pp fmt = function
    | Geographic cs -> GeogCS.pp fmt cs
    | Projected cs -> ProjCS.pp fmt cs
    | Geocentric cs -> GeocCS.pp fmt cs
    | Vert cs -> VertCS.pp fmt cs
    | Compd (name, head_cs, tail_cs, authority) ->
	Format.fprintf fmt {|COMPD_CS["%s", %a, %a%a]|}
	  name pp head_cs pp tail_cs
	  (pp_opt Authority.pp) authority
    | Fitted (name, to_base, base_cs) ->
	Format.fprintf fmt {|FITTED_CS["%s", %a, %a]|}
	  name MT.pp to_base pp base_cs
    | Local cs -> LocalCS.pp fmt cs
end
