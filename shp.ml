let b2f = Int64.float_of_bits
let b2i = Int32.to_int

let xy = 2 and xym = 3 and xyzm = 4
type point = float array
type bbox = float array

let get_float = fun bits ->
  bitmatch bits with
  | { v: 64 : littleendian, bind (b2f v); rem: -1 : bitstring } -> v, rem

let make_point = fun size bits ->
  let bits = ref bits in
  let p = Array.init size (fun _ ->
    let v, rem = get_float !bits in
    bits := rem; v) in
  p, !bits

let make_bbox = fun size -> make_point (2 * size)

let make_parts = fun n bits ->
  let bparts = ref bits in
  Array.init n (fun i ->
    let idx, rest = bitmatch !bparts with
	      | { idx: 32 : littleendian; r: -1 : bitstring } -> b2i idx, r
	      | { _ } -> failwith "Shp.make_parts" in
    bparts := rest; idx)

let make_points = fun size n bits ->
  let bpoints = ref bits in
  Array.init n (fun _ ->
    let p, rest = make_point size bits in
    bpoints := rest; p)

let make_rings = fun size nparts npoints parts points ->
  let parts = make_parts nparts parts
  and points = make_points size npoints points in
  Array.init nparts (fun i ->
    Array.sub points parts.(i)
      ((if i < nparts - 1 then parts.(i+1) else npoints) - parts.(i)))

let multipoint = fun size bits ->
  let bbox, bits = make_bbox size bits in
  bitmatch bits with
  | { npoints: 32 : littleendian, bind (b2i npoints);
      points: size * 64 * npoints : bitstring;
      rest: -1 : bitstring } ->
	bbox, make_points size npoints points, rest

let multishape = fun size bits ->
  let bbox, bits = make_bbox size bits in
  bitmatch bits with
  | { nparts: 32 : littleendian, bind (b2i nparts);
      npoints: 32 : littleendian, bind (b2i npoints);
      parts: 32 * nparts : bitstring;
      points: size * 64 * npoints : bitstring;
      rest: -1 : bitstring } ->
	let shapes = make_rings size nparts npoints parts points in
	bbox, shapes, rest

module XY = struct

  let size = 2

  type point = { x: float; y: float }

  let print_point = fun p -> Printf.printf "x = %f, y = %f" p.x p.y

  type bbox = { xmin: float; xmax: float; ymin: float; ymax: float }

  let print_bbox = fun b ->
    Printf.printf "xmin = %f, xmax = %f\n" b.xmin b.xmax;
    Printf.printf "ymin = %f, ymax = %f\n" b.ymin b.ymax

end

module XYM = struct

  type point = { x: float; y: float; m: float }

  let print_point = fun p ->
    Printf.printf "x = %f, y = %f, m = %f\n" p.x p.y p.m

  type bbox = { xmin: float; xmax: float; ymin: float; ymax: float;
		mmin: float; mmax: float }

  let print_bbox = fun b ->
    Printf.printf "xmin = %f, xmax = %f\n" b.xmin b.xmax;
    Printf.printf "ymin = %f, ymax = %f\n" b.ymin b.ymax;
    Printf.printf "mmin = %f, mmax = %f\n" b.mmin b.mmax

end

module XYZM = struct

  type point = { x: float; y: float; z: float; m: float }

  let print_point = fun p ->
    Printf.printf "x = %f, y = %f, z = %f, m = %f\n" p.x p.y p.z p.m

  type bbox = { xmin: float; xmax: float; ymin: float; ymax: float;
		zmin: float; zmax: float; mmin: float; mmax: float }

  let print_bbox = fun b ->
    Printf.printf "xmin = %f, xmax = %f\n" b.xmin b.xmax;
    Printf.printf "ymin = %f, ymax = %f\n" b.ymin b.ymax;
    Printf.printf "zmin = %f, zmax = %f\n" b.zmin b.zmax;
    Printf.printf "mmin = %f, mmax = %f\n" b.mmin b.mmax

  let make_bbox = fun bits -> (* TODO : must disappear *)
    bitmatch bits with
    | { xmin: 64 : littleendian, bind (b2f xmin);
	ymin: 64 : littleendian, bind (b2f ymin);
	xmax: 64 : littleendian, bind (b2f xmax);
	ymax: 64 : littleendian, bind (b2f ymax);
	zmin: 64 : littleendian, bind (b2f zmin);
	zmax: 64 : littleendian, bind (b2f zmax);
	mmin: 64 : littleendian, bind (b2f mmin);
	mmax: 64 : littleendian, bind (b2f mmax);
	rest: -1 : bitstring } ->
	  { xmin; xmax; ymin; ymax; zmin; zmax; mmin; mmax }, rest

end

type header = { length: int; version: int; shape_type: int; bbox: XYZM.bbox }

let print_header = fun h ->
  Printf.printf "file length = %d\n%!" h.length;
  Printf.printf "version = %d\n%!" h.version;
  Printf.printf "type = %d\n%!" h.shape_type;
  XYZM.print_bbox h.bbox

let header = fun bits ->
  bitmatch bits with
  | { code: 32 : bigendian, check (b2i code = 9994);
      _: 5 * 32 : bitstring; (* 5 unused fields (32 bits each) *)
      length: 32 : bigendian, bind (b2i length);
      version: 32 : littleendian, bind (b2i version);
      shape_type: 32 : littleendian, bind (b2i shape_type);
      rest: -1 : bitstring } ->
	let bbox, contents = XYZM.make_bbox rest in
	{ length; version; shape_type; bbox }, contents
  | { _ } -> failwith "Shp.header"

let record_header = fun bits ->
  bitmatch bits with
  | { n: 32 : bigendian; l: 32 : bigendian; payload: -1 : bitstring } ->
      b2i n, b2i l, payload
  | {_} -> failwith "Shp.record_header"

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

let record = fun bits ->
  let shape_type, bits = bitmatch bits with
  | { shp: 32 : littleendian, bind (b2i shp); r: -1 : bitstring } -> shp, r in
  match shape_type with
  | 00 -> Null, bits
  | 01 -> let p, r = make_point xy bits in Point p, r
  | 11 -> let p, r = make_point xyzm bits in PointZ p, r
  | 21 -> let p, r = make_point xym bits in PointM p, r
  | 08 -> let box, pts, r = multipoint xy bits in MultiPoint (box, pts), r
  | 18 -> let box, pts, r = multipoint xyzm bits in MultiPointZ (box, pts), r
  | 28 -> let box, pts, r = multipoint xym bits in MultiPointM (box, pts), r
  | 03 -> let box, shps, r = multishape xy bits in PolyLine (box, shps), r
  | 05 -> let box, shps, r = multishape xy bits in Polygon (box, shps), r
  | 13 -> let box, shps, r = multishape xyzm bits in PolyLineZ (box, shps), r
  | 15 -> let box, shps, r = multishape xyzm bits in PolygonZ (box, shps), r
  | 23 -> let box, shps, r = multishape xym bits in PolyLineM (box, shps), r
  | 25 -> let box, shps, r = multishape xym bits in PolygonM (box, shps), r
  | 31 -> failwith "Not implemented"
  | _ -> failwith "Not a documented shape"

let records = fun bits ->
  let res = ref [] and bits = ref bits in
  while Bitstring.bitstring_length !bits > 0 do
    let _number, _length, payload = record_header !bits in
    let record, rest = record payload in
    res := record :: !res;
    bits := rest
  done; List.rev !res

let read = fun file ->
  let bits = Bitstring.bitstring_of_file file in
  let header, contents = header bits in
  records contents
