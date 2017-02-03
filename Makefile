NAME = shp
SRC = d2.ml d2M.ml d3M.ml common.ml shp.ml shx.ml \
      prj_syntax.ml prj_parser.mly prj_lexer.mll prj.ml

REQUIRES = "bitstring bitstring.syntax"

OCAML = `ocamlfind printconf path`
SYNTAX = camlp4of -I $(OCAML)/bitstring bitstring.cma bitstring_persistent.cma pa_bitstring.cmo
PP = -pp "$(SYNTAX)"

OCAMLC    = ocamlfind ocamlc -g -annot
OCAMLOPT  = ocamlfind ocamlopt -noassert -inline 100
OCAMLDOC  = ocamlfind ocamldoc
OCAMLYACC = ocamlyacc -v
OCAMLLEX  = ocamllex.opt
OCAMLDEP  = ocamldep.opt

MLYS = $(filter %.mly, $(SRC))
MLLS = $(filter %.mll, $(SRC))
AUX_MLS = $(MLYS:.mly=.mli) $(MLYS:.mly=.ml) $(MLLS:.mll=.ml)

SRC_INTER = $(SRC:.mly=.ml)
FILES = $(SRC_INTER:.mll=.ml)

OBJS = $(FILES:.ml=.cmo)
XOBJS = $(FILES:.ml=.cmx)

LIB = $(NAME).cma
XLIB = $(NAME).cmxa

DOC_DIR = doc/
MLIS = $(SRC:.ml=.mli)

.PHONY : all
all: $(LIB) $(XLIB)
	@echo Building successful

$(LIB): $(OBJS)
	@echo "Creating byte library $@                  "
	@$(OCAMLC) -a -o $@ -package $(REQUIRES) $(PP) $^
$(XLIB): $(XOBJS)
	@echo "Creating native library $@                "
	@$(OCAMLOPT) -a -o $@ -package $(REQUIRES) $(PP) $^

.SUFFIXES: .ml .mli .cmo .cmi .cmx .mly .mll
%.cmo: %.ml
	@echo -n "Compiling $< to $@\r"
	@$(OCAMLC) -package $(REQUIRES) $(PP) -c $<
%.cmi: %.mli
	@echo -n "Compiling interface $<\r"
	@$(OCAMLC) -package $(REQUIRES) $(PP) $<
%.cmx: %.ml
	@echo -n "Compiling $< to $@\r"
	@$(OCAMLOPT) -package $(REQUIRES) $(PP) -c $<
%.ml %.mli: %.mly
	@echo Building parser from $<
	@$(OCAMLYACC) $<
%.ml: %.mll
	@echo Building lexical analyser from $<:
	@$(OCAMLLEX) $<

.PHONY : doc clean clean_doc
doc : $(MLIS)
	@echo Building doc in $(DOC_DIR)
	@mkdir -p $(DOC_DIR)
	@$(OCAMLDOC) -html -d $(DOC_DIR) -package $(REQUIRES) $^
clean:
	@echo Cleaning build
	@rm -f *.cm[iox] $(AUX_MLS) $(LIB) $(XLIB) *.o *.output $(NAME).a *~ *.annot .depend
	@touch .depend
cleandoc :
	@echo Cleaning doc
	@rm -rf $(DOC_DIR)

.depend: $(FILES)
	@echo Computing dependencies
	@$(OCAMLDEP) $(PP) *.mli *.ml *.mly *.mll > .depend

include .depend

.PHONY : install uninstall update
install : all
	@ocamlfind install $(NAME) *.mli *.cmi $(LIB) $(XLIB) $(NAME).a META

uninstall :
	@ocamlfind remove $(NAME)

update :
	@ocamlfind remove $(NAME)
	@ocamlfind install $(NAME) *.mli *.cmi $(LIB) $(XLIB) $(NAME).a META
