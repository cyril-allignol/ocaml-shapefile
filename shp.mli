module XY : sig
  type point = { x: float; y: float }
  type bbox = { xmin: float; xmax: float; ymin: float; ymax: float }
end

module XYM : sig
  type point = { x: float; y: float; m: float }
  type bbox = { xmin: float; xmax: float; ymin: float; ymax: float;
		mmin: float; mmax: float }
end

module XYZM : sig
  type point = { x: float; y: float; z: float; m: float }
  type bbox = { xmin: float; xmax: float; ymin: float; ymax: float;
		zmin: float; zmax: float; mmin: float; mmax: float }
end

type point = float array
type bbox = float array

(*
type shape =
  | Null
  | Point of XY.point
  | MultiPoint of XY.bbox * XY.point array
  | PolyLine of XY.bbox * XY.point array array
  | Polygon of XY.bbox * XY.point array array
  | PointM of XYM.point
  | PolyLineM of XYM.bbox * XYM.point array array
  | PolygonM of XYM.bbox * XYM.point array array
  | MultiPointM of XYM.bbox * XYM.point array
  | PointZ of XYZM.point
  | PolyLineZ of XYZM.bbox * XYZM.point array array
  | PolygonZ of XYZM.bbox * XYZM.point array array
  | MultiPointZ of XYZM.bbox * XYZM.point array
  | MultiPatch
*)

type shape =
  | Null
  | Point of point
  | MultiPoint of bbox * point array
  | PolyLine of bbox * point array array
  | Polygon of bbox * point array array
  | PointM of point
  | PolyLineM of bbox * point array array
  | PolygonM of bbox * point array array
  | MultiPointM of bbox * point array
  | PointZ of point
  | PolyLineZ of bbox * point array array
  | PolygonZ of bbox * point array array
  | MultiPointZ of bbox * point array
  | MultiPatch

val read: string -> shape list
