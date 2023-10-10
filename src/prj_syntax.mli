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

module Parameter : sig
  type t = { name: string; value: float }
  val pp: Format.formatter -> t -> unit
end

module MT : sig (** Math Transform *)
  type t =
    | Param of string * Parameter.t list
    | Concat of t list
    | Inverse of t
    | Passthrough of int * t
  val pp: Format.formatter -> t -> unit
end

module Authority : sig
  type t = { name: string; code: string }
  val pp: Format.formatter -> t -> unit
end

module Axis : sig
  type direction = North | South | East | West | Up | Down | Other
  type t = {
      name: string;        (** for humans only *)
      direction: direction (** axis direction *)
    } (** Defines axes for correct overlay with different Coordinate Systems.
	  If not provided, the default values are the following:
	  - Geographic CS: AXIS["Lon", EAST], AXIS["Lat", NORTH]
	  - Projected CS: AXIS["X", EAST], AXIS["Y", NORTH]
	  - Geocentric CS: AXIS["X", OTHER], AXIS["Y", EAST], AXIS["Z", NORTH]
       *)
  val pp: Format.formatter -> t -> unit
  val pp_dir: Format.formatter -> direction -> unit
  val geographic_default: t * t
  val projected_default: t * t
  val geocentric_default: t * t * t
end

module Unit : sig
  type t = {
      name: string; (** unit name *)
      cf: float; (** conversion factor to radian or meter *)
      authority: Authority.t option (** related authority, if any *)
    } (** Describes an angular or linear unit, depending on the context. *)
  val pp: Format.formatter -> t -> unit
end

module Primem : sig
  type t = {
      name: string; (** name of the prime meridian *)
      longitude: float; (** angle relative to the Greenwich Meridian, positive
			    when east of Greenwich Meridian *)
      authority: Authority.t option (** related authority, if any *)
    } (** Reference meridian for measurements. Unit for the longitude depends
	  on the context. *)
  val pp: Format.formatter -> t -> unit
end

module ToWGS84 : sig
  type t = { dx: float; dy: float; dz: float;
	     ex: float; ey: float; ez: float;
	     ppm: float }
  val pp: Format.formatter -> t -> unit
end

module Spheroid : sig
  type t = { name: string; a: float; f: float; authority: Authority.t option }
  val pp: Format.formatter -> t -> unit
end

module Datum : sig
  type t = { name: string; spheroid: Spheroid.t;
	     toWGS84: ToWGS84.t option; authority: Authority.t option }
  val pp: Format.formatter -> t -> unit
end

module Vert_datum : sig
  type t = { name: string; datum_type: float; authority: Authority.t option }
  val pp: Format.formatter -> t -> unit
end

module Local_datum : sig
  type t = { name: string; datum_type: float; authority: Authority.t option }
  val pp: Format.formatter -> t -> unit
end

module Projection : sig
  type t = { name: string; authority: Authority.t option }
  val pp: Format.formatter -> t -> unit
end

module GeogCS : sig
  type t = { name: string; datum: Datum.t; prime_meridian: Primem.t;
	     angular_unit: Unit.t; axes: Axis.t * Axis.t;
	     authority: Authority.t option }
  val pp: Format.formatter -> t -> unit
end

module ProjCS : sig
  type t = { name: string; geogcs: GeogCS.t; projection: Projection.t;
	     params: Parameter.t list; linear_unit: Unit.t;
	     axes: Axis.t * Axis.t; authority: Authority.t option }
  val pp: Format.formatter -> t -> unit
end

module GeocCS : sig
  type t = { name: string; datum: Datum.t; prime_meridian: Primem.t;
	     linear_unit: Unit.t; axes: Axis.t * Axis.t * Axis.t;
	     authority: Authority.t option }
  val pp: Format.formatter -> t -> unit
end

module VertCS : sig
  type t = { name: string; datum: Vert_datum.t; linear_unit: Unit.t;
	     axis: Axis.t; authority: Authority.t option }
  val pp: Format.formatter -> t -> unit
end

module LocalCS : sig
  type t = { name: string; datum: Local_datum.t; unit: Unit.t;
	     axes: Axis.t list; authority: Authority.t option }
  val pp: Format.formatter -> t -> unit
end

module CS : sig
  type t =
    | Geographic of GeogCS.t
    | Projected of ProjCS.t
    | Geocentric of GeocCS.t
    | Vert of VertCS.t
    | Compd of string * t * t * Authority.t option
    | Fitted of string * MT.t * t
    | Local of LocalCS.t
  val pp: Format.formatter -> t -> unit
end
