let dim = 4

type point = { x: float; y: float; z: float; m: float }

let a2p = fun p -> { x = p.(0); y = p.(1); z = p.(2); m = p.(3) }

type bbox = { xmin: float; xmax: float; ymin: float; ymax: float;
	      zmin: float; zmax: float; mmin: float; mmax: float }

let print_bbox = fun b ->
  Printf.printf "xmin = %f, xmax = %f\n" b.xmin b.xmax;
  Printf.printf "ymin = %f, ymax = %f\n" b.ymin b.ymax;
  Printf.printf "zmin = %f, zmax = %f\n" b.zmin b.zmax;
  Printf.printf "mmin = %f, mmax = %f\n" b.mmin b.mmax


let a2b = fun b ->
  { xmin = b.(0); xmax = b.(2); ymin = b.(1); ymax = b.(3);
    zmin = b.(4); zmax = b.(5); mmin = b.(6); mmax = b.(7) }
