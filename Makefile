NAME = shp
SRC = shp.ml

REQUIRES = "bitstring bitstring.syntax"

PP = -pp "camlp4of -I /usr/lib/ocaml/bitstring bitstring.cma bitstring_persistent.cma pa_bitstring.cmo"

OCAMLC   = ocamlfind ocamlc -g -annot
OCAMLOPT = ocamlfind ocamlopt -unsafe -noassert -inline 100
OCAMLDOC = ocamlfind ocamldoc
OCAMLDEP = ocamldep.opt

OBJS = $(SRC:.ml=.cmo)
XOBJS = $(SRC:.ml=.cmx)

LIB = $(NAME).cma
XLIB = $(NAME).cmxa

DOC_DIR = doc/
MLIS = $(SRC:.ml=.mli)

.PHONY : all
all: .depend $(LIB) $(XLIB)

$(LIB): $(OBJS)
	$(OCAMLC) -a -o $@ -package $(REQUIRES) $(PP) $^
$(XLIB): $(XOBJS)
	$(OCAMLOPT) -a -o $@ -package $(REQUIRES) $(PP) $^

.SUFFIXES: .ml .mli .cmo .cmi .cmx
%.cmo: %.ml
	$(OCAMLC) -package $(REQUIRES) $(PP) -c $<
%.cmi: %.mli
	$(OCAMLC) -package $(REQUIRES) $(PP) $<
%.cmx: %.ml
	$(OCAMLOPT) -package $(REQUIRES) $(PP) -c $<

.PHONY : doc clean clean_doc
doc : $(MLIS)
	mkdir -p $(DOC_DIR)
	$(OCAMLDOC) -html -d $(DOC_DIR) $^
clean:
	rm -f *.cm[iox] $(LIB) $(XLIB) *.o $(NAME).a *~ *.annot .depend
cleandoc :
	rm -rf $(DOC_DIR)

.depend:
	$(OCAMLDEP) $(PP) *.mli *.ml >.depend

include .depend

.PHONY : install uninstall update
install : all
	@ocamlfind install $(NAME) *.mli *.cmi $(LIB) $(XLIB) $(NAME).a META

uninstall :
	@ocamlfind remove $(NAME)

update :
	@ocamlfind remove $(NAME)
	@ocamlfind install $(NAME) *.mli *.cmi $(LIB) $(XLIB) $(NAME).a META
