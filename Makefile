NAME = shp

BUILD = ocamlbuild -use-ocamlfind -quiet -j 0

INSTALL_FILES = $(NAME) META *.mli _build/*.cmi _build/$(NAME).cma
OPT_INSTALL_FILES = _build/*.cmx _build/$(NAME).cmxa _build/$(NAME).a

all: $(NAME).cma $(NAME).cmxa

%:
	@echo -n "Building $@... "; $(BUILD) $@; echo "done"

doc:
	@$(BUILD) $(NAME).docdir/index.html

clean:
	@$(BUILD) -clean

update:
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
	@ocamlfind install $(INSTALL_FILES) -optional $(OPT_INSTALL_FILES)
uninstall:
	@ocamlfind remove $(NAME)

.PHONY: all doc clean install uninstall update
