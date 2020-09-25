# OCaml shapefile library

A small library to read shapefiles. The implementation follows the
technical description provided by ESRI
(https://www.esri.com/library/whitepapers/pdfs/shapefile.pdf).

## Install
```
opam install shapefile
```

## Build

If you want to build the library from source, you will need dune, menhir and ppx_bitstring:
```
opam install dune menhir ppx_bitstring
```

Then the usual:
```
make
make install
```

## License

This library is licensed under the Apache License, Version 2.0.
