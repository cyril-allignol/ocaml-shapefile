type point = { x: float; y: float; z: float; m: float }

let print_point = fun p -> Printf.printf "x=%f y=%f z=%f m=%f\n" p.x p.y p.z p.m

type bbox = {
    xmin: float; xmax: float; ymin: float; ymax: float;
    zmin: float; zmax: float; mmin: float; mmax: float }

let bbox = fun xmin xmax ymin ymax zmin zmax mmin mmax ->
  let xmin = Int64.float_of_bits xmin and ymin = Int64.float_of_bits ymin
  and xmax = Int64.float_of_bits xmax and ymax = Int64.float_of_bits ymax
  and zmin = Int64.float_of_bits zmin and zmax = Int64.float_of_bits zmax
  and mmin = Int64.float_of_bits mmin and mmax = Int64.float_of_bits mmax in
  { xmin; xmax; ymin; ymax; zmin; zmax; mmin; mmax }

let bbox2D = fun xmin xmax ymin ymax -> bbox xmin xmax ymin ymax 0L 0L 0L 0L
let bbox2DM = fun xmin xmax ymin ymax mmin mmax ->
  bbox xmin xmax ymin ymax 0L 0L mmin mmax

let print_bbox = fun b ->
  Printf.printf "xmin = %f, xmax = %f\n" b.xmin b.xmax;
  Printf.printf "ymin = %f, ymax = %f\n" b.ymin b.ymax;
  Printf.printf "zmin = %f, zmax = %f\n" b.zmin b.zmax;
  Printf.printf "mmin = %f, mmax = %f\n" b.mmin b.mmax

type header = { length: int; version: int; shape_type: int; bbox: bbox }

let print_header = fun h ->
  Printf.printf "file length = %d\n%!" h.length;
  Printf.printf "version = %d\n%!" h.version;
  Printf.printf "type = %d\n%!" h.shape_type;
  print_bbox h.bbox

let header = fun bits ->
  bitmatch bits with
  | { code: 32 : bigendian, check (Int32.to_int code = 9994);
      _: 5 * 32 : bitstring; (* 5 unused fields (32 bits each) *)
      length: 32 : bigendian; version: 32 : littleendian;
      shape_type: 32 : littleendian;
      xmin: 64 : littleendian; ymin: 64 : littleendian;
      xmax: 64 : littleendian; ymax: 64 : littleendian;
      zmin: 64 : littleendian; zmax: 64 : littleendian;
      mmin: 64 : littleendian; mmax: 64 : littleendian;
      contents: -1 : bitstring
    } ->
      let bbox = bbox xmin xmax ymin ymax zmin zmax mmin mmax in
      let length = Int32.to_int length and version = Int32.to_int version
      and shape_type = Int32.to_int shape_type in
      { length; version; shape_type; bbox }, contents
  | {_} -> failwith "Shp.header"

let record_header = fun bits ->
  bitmatch bits with
  | { n: 32 : bigendian; l: 32 : bigendian; payload: -1 : bitstring } ->
      Int32.to_int n, Int32.to_int l, payload
  | {_} -> failwith "Shp.record_header"

let make_parts = fun n bits ->
  let bparts = ref bits in
  Array.init n (fun i ->
    let idx, rest = bitmatch !bparts with
      | { idx: 32 : littleendian; r: -1 : bitstring } -> Int32.to_int idx, r
      | {_} -> failwith "Shp.make_parts" in
    bparts := rest; idx)

let make_points2D = fun n bits ->
  let bpoints = ref bits in
  Array.init n (fun i ->
    let x, y, rest = bitmatch !bpoints with
      | { x: 64 : littleendian; y: 64 : littleendian; r: -1 : bitstring } ->
	  Int64.float_of_bits x, Int64.float_of_bits y, r
      | {_} -> failwith "Shp.make_points2D" in
    bpoints := rest; { x; y; z = 0.; m = 0. })

let make_rings = fun nparts npoints parts points ->
  let parts = make_parts nparts parts
  and points = make_points2D npoints points in
  Array.init nparts (fun i ->
    Array.sub points parts.(i)
      ((if i < nparts - 1 then parts.(i+1) else npoints) - parts.(i)))

type multi = { shp_bbox: bbox; rings: point array array }

type shape =
  | Null | Point | PolyLine
  | Polygon of multi
  | MultiPoint
  | PointZ | PolyLineZ | PolygonZ | MultiPointZ
  | PointM | PolyLineM | PolygonM | MultiPointM | MultiPatch

let record = fun bits ->
  bitmatch bits with
  | { shape: 32 : littleendian, check (Int32.to_int shape = 5); (* Polygon *)
      xmin: 64 : littleendian; ymin: 64 : littleendian;
      xmax: 64 : littleendian; ymax: 64 : littleendian;
      nparts: 32 : littleendian; npoints: 32 : littleendian;
      parts: 32 * (Int32.to_int nparts) : bitstring;
      points: 128 * (Int32.to_int npoints) : bitstring;
      rest: -1 : bitstring
    } ->
      let shp_bbox = bbox2D xmin xmax ymin ymax in
      let nparts = Int32.to_int nparts and npoints = Int32.to_int npoints in
      let rings = make_rings nparts npoints parts points in
      Polygon { shp_bbox; rings }, rest

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
