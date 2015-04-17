(** .shx files utilities. *)

type index = {
    offset: int; (** postion of the shape in the .shp file in 16-bits words *)
    length: int  (** length of the shape description in 16-bits words *)
  } (** Type of an index record. *)

val read: string -> index list
(** [Shx.read file] parses the [file] and returns a list of indexes,
    i.e. position and size of shape descriptions found in the corresponding
    .shp file. *)
