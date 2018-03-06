let dim = 2

type point = { x: float; y: float }

let a2p = fun p -> { x = p.(0); y = p.(1) }

type bbox = { xmin: float; xmax: float; ymin: float; ymax: float }

let a2b = fun b -> { xmin = b.(0); xmax = b.(2); ymin = b.(1); ymax = b.(3) }

let print_bbox = fun b ->
  Printf.printf "xmin = %f, xmax = %f\n" b.xmin b.xmax;
  Printf.printf "ymin = %f, ymax = %f\n" b.ymin b.ymax
