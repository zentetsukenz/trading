workdir = $(shell pwd)
gen_path = gen/trading
doc_path = doc
protos_path = protos

init:
	mkdir -p $(gen_path)

install: arbitrage

# =====
# Arbitrage
#

arbitrage_python_path = $(gen_path)/arbitrage/python
arbitrage_elixir_path = $(gen_path)/arbitrage/elixir
arbitrage_proto_path = $(protos_path)/arbitrage.proto

arbitrage: arbitrage_python arbitrage_elixir arbitrage_doc

# - Python

arbitrage_python:
	mkdir -p $(arbitrage_python_path)
	python -m grpc_tools.protoc \
		-Iprotos \
		--python_out=$(arbitrage_python_path) \
		--grpc_python_out=$(arbitrage_python_path) \
		$(arbitrage_proto_path)

# - Elixr

arbitrage_elixir:
	mkdir -p $(arbitrage_elixir_path)
	protoc -Iprotos --elixir_out=plugins=grpc:$(arbitrage_elixir_path) $(arbitrage_proto_path)

# - Document

arbitrage_doc:
	mkdir -p $(doc_path)
	docker run --rm \
		-v $(workdir)/$(doc_path):/out \
		-v $(workdir)/$(protos_path):/protos \
		pseudomuto/protoc-gen-doc

# Utils =====

clean:
	rm -rf gen
