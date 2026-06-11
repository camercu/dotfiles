test:
	nvim --headless --clean -u ./tests/minimal_init.lua \
		-c "lua MiniTest.run()"

# Use `make test_xxx` to run tests/test_xxx.lua
TEST_MODULES = $(basename $(notdir $(wildcard tests/test_*.lua)))

$(TEST_MODULES):
	nvim --headless --clean -u ./tests/minimal_init.lua \
		-c "lua MiniTest.run_file('tests/$@.lua')"

.PHONY: test $(TEST_MODULES)
