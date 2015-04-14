type point = { x: float; y: float; z: float; m: float }
type bbox = { xmin: float; xmax: float; ymin: float; ymax: float;
	      zmin: float; zmax: float; mmin: float; mmax: float }

type points = point array

type shape =
  | Null
  | Point of point
  | MultiPoint of bbox * points
  | PolyLine of bbox * points array
  | Polygon of bbox * points array
  | PointZ | PolyLineZ | PolygonZ | MultiPointZ
  | PointM | PolyLineM | PolygonM | MultiPointM | MultiPatch

val read: string -> shape list
