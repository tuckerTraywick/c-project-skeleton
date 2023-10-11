ARGS :=
LIBRARIES := 
CFLAGS := -g -Wall -std=c17
VALGRIND_FLAGS := --leak-check=yes
CC := gcc

SRC_FILES := $(shell find source -name '*.c')
OBJ_FILES := $(SRC_FILES:%=build/%.o)
D_FILES := $(SRC_FILES:%=build/%.d)

TEST_SRC_FILES := $(shell find test -name '*.c')
TEST_OBJ_FILES := $(TEST_SRC_FILES:%=build/%.o)
TEST_D_FILES := $(TEST_SRC_FILES:%=build/%.d)

.PRECIOUS: build/%.d

build: buildmessage binary/run binary/test

buildmessage:
	@echo "--- BUILDING ---"

binary/run: $(OBJ_FILES)
	@mkdir -p binary
	$(CC) $(LDFLAGS) $(LIBRARIES) $^ -o $@

binary/test: $(TEST_OBJ_FILES)
	@mkdir -p binary
	$(CC) $(LDFLAGS) $(LIBRARIES) $^ -o $@

build/source/%.o: source/%
	@mkdir -p $(dir $@)
	$(CC) -c -MMD -MP -MT $@ -MF build/source/$*.d -Iinclude $(CFLAGS) $(LIBRARIES) source/$* -o $@

build/test/%.o: test/%
	@mkdir -p $(dir $@)
	$(CC) -c -MMD -MP -MT $@ -MF build/test/$*.d -Iinclude -Isource -Itest $(CFLAGS) $(LIBRARIES) test/$* -o $@

.PHONY: run
run: build
	@echo "\n--- RUNNING ---" && binary/run $(ARGS)

.PHONY: valgrind
valgrind: build
	@echo "\n--- RUNNING IN VALGRIND ---" && valgrind $(VALGRIND_FLAGS) binary/run $(ARGS)

.PHONY: test
test: build
	@echo "\n--- TESTING ---" && binary/test

.PHONY: testandrun
testandrun: build test run

.PHONY: clean
clean:
	@rm -rf build binary

-include $(D_FILES) $(TEST_D_FILES)
