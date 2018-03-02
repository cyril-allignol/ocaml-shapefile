let dim = 3

type point = { x: float; y: float; m: float }

let a2p = fun p -> { x = p.(0); y = p.(1); m = p.(2) }

type bbox = { xmin: float; xmax: float; ymin: float; ymax: float;
	      mmin: float; mmax: float }

let a2b = fun b ->
  { xmin = b.(0); xmax = b.(2); ymin = b.(1); ymax = b.(3);
    mmin = b.(6); mmax = b.(7) }

let print_bbox = fun b ->
  Printf.printf "xmin = %f, xmax = %f\n" b.xmin b.xmax;
  Printf.printf "ymin = %f, ymax = %f\n" b.ymin b.ymax;
  Printf.printf "mmin = %f, mmax = %f\n" b.mmin b.mmax
