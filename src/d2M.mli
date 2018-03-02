(** Types for 2D + value (x, y, m) shapes *)

type point = { x: float; y: float; m: float }
type bbox = { xmin: float; xmax: float; ymin: float; ymax: float;
	      mmin: float; mmax: float }

(**/**)
val dim: int
val a2p: float array -> point
val a2b: float array -> bbox
