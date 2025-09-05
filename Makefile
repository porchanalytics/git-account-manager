.PHONY: fmt lint test bootstrap clean

fmt:
	shfmt -i 2 -ci -sr -w .

lint:
	scripts/lint.sh

test:
	bats tests

# optional convenience
bootstrap:
	scripts/install.sh --yes

clean:
	rm -rf tmp .tmp tools **/*.swp **/*.swo || true
