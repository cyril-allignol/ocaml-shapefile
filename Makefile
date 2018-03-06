NAME = shapefile

BUILD = ocamlbuild -use-ocamlfind -quiet -j 0

INSTALL_FILES = META src/*.mli _build/src/*.cmi _build/src/$(NAME).cma
OPT_INSTALL_FILES = _build/src/*.cmx _build/src/$(NAME).cmxa _build/src/$(NAME).a

all: src/$(NAME).cma src/$(NAME).cmxa

%:
	@echo -n "Building $@... "; $(BUILD) $@; echo "done"

doc:
	@$(BUILD) $(NAME).docdir/index.html

clean:
	@$(BUILD) -clean

reinstall:
	@$(MAKE) uninstall
	@$(MAKE) install

install:
	@ocamlfind install $(NAME) $(INSTALL_FILES) -optional $(OPT_INSTALL_FILES)
uninstall:
	@ocamlfind remove $(NAME)

.PHONY: all doc clean install uninstall update
