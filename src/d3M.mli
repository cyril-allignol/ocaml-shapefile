(** Types for 3D + value (x, y, z, m) shapes *)

type point = { x: float; y: float; z: float; m: float }
type bbox = { xmin: float; xmax: float; ymin: float; ymax: float;
	      zmin: float; zmax: float; mmin: float; mmax: float }

(**/**)
val dim: int
val print_bbox: bbox -> unit
val a2p: float array -> point
val a2b: float array -> bbox
