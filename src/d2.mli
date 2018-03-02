(** Types for 2D (x, y) shapes *)

type point = { x: float; y: float }
type bbox = { xmin: float; xmax: float; ymin: float; ymax: float }

(**/**)
val dim: int
val a2p: float array -> point
val a2b: float array -> bbox
