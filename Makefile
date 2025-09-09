.PHONY: test
test:
	@echo "Running tests…"
	nvim --headless -u spec/minimal_init.lua \
	  +"PlenaryBustedDirectory spec" \
	  +qa
