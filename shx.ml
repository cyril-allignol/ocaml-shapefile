open Common

type index = { offset: int; length: int }

let record = fun bits ->
  bitmatch bits with
  | { offset: 32 : bigendian, bind (b2i offset);
      length: 32 : bigendian, bind (b2i length);
      r: -1 : bitstring } -> { offset; length }, r

let records = fun bits ->
  let res = ref [] and bits = ref bits in
  while Bitstring.bitstring_length !bits > 0 do
    let index, rest = record !bits in
    res := index :: !res;
    bits := rest
  done; List.rev !res

let read = fun file ->
  let bits = Bitstring.bitstring_of_file file in
  let header, contents = header bits in
  records contents
