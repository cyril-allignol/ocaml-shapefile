NAME = shp

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

$(NAME).install:
	@echo 'lib: [' >>$@
	@echo '  "META"' >>$@
	@echo '  "_build/$(NAME).cma"' >>$@
	@echo '  "?_build/$(NAME).cmxa"' >>$@
	@echo '  "?_build/$(NAME).a"' >>$@
	@$(foreach x,$(wildcard _build/*.mli), echo '  "$x"' >>$@;)
	@$(foreach x,$(wildcard _build/*.cmi), echo '  "$x"' >>$@;)
	@$(foreach x,$(wildcard _build/*.cmx), echo '  "?$x"' >>$@;)
	@echo ']' >>$@
	@echo 'doc: [' >>$@
	@$(foreach x,$(wildcard _build/$(NAME).docdir/*.html), echo '  "$x"' >>$@;)
	@echo ']' >>$@

install:
	@ocamlfind install $(NAME) $(INSTALL_FILES) -optional $(OPT_INSTALL_FILES)
uninstall:
	@ocamlfind remove $(NAME)

.PHONY: all doc clean install uninstall update
