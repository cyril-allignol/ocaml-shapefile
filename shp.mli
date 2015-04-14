type point = { x: float; y: float; z: float; m: float }
type bbox = { xmin: float; xmax: float; ymin: float; ymax: float;
	      zmin: float; zmax: float; mmin: float; mmax: float }
type multi = { shp_bbox: bbox; rings: point array array }

type shape =
  | Null | Point | PolyLine
  | Polygon of multi
  | MultiPoint
  | PointZ | PolyLineZ | PolygonZ | MultiPointZ
  | PointM | PolyLineM | PolygonM | MultiPointM | MultiPatch

val read: string -> shape list
