(lang dune 3.0)

(using menhir 2.0)
(implicit_transitive_deps false)
(generate_opam_files true)

(name shapefile)

(license  Apache-2.0)

(authors "Cyril Allignol <cyril@allignol.com>")

(maintainers "Cyril Allignol <cyril@allignol.com>")

(source
  (github cyril-allignol/ocaml-shapefile))

(package
  (name shapefile)
  (synopsis "Library for the manipulation of shapefiles")
  (description "OCaml library for the manipulation of ESRI shapefiles (.shp, .shx, .prj).")
  (tags (shapefile esri shp shx prj map geospatial geographic))
  (depends
    ocaml
    (bitstring (>= 4.0.0))
    (menhir :build)
    (ppx_bitstring (and :build (>= 4.0.0)))
    ))
