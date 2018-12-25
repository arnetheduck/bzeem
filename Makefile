
all: bin/extract_zim

CLEAN=bin .crates.toml

cargo:
	@cargo -V > /dev/null 2>&1 || (echo 'You have to install cargo and Rust'; exit 1)
.PHONY: cargo

bin/extract_zim: cargo
	cargo install --force --bin extract_zim --rev d5c056f50a1962d9d9a9df8b838f8023d2fa5714 --git https://github.com/arnetheduck/zim --root .

clean:
	rm -rf $(CLEAN)
.PHONY: clean
