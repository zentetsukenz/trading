workdir = $(shell pwd)

all_protos = $(basename $(subst protos/,,$(shell find protos/ -name "*.proto")))

gen_python_base_path = gen/python/
gen_elixir_base_path = gen/elixir/

all: python elixir doc

python: $(addsuffix _pb2_grpc.py,$(basename $(addprefix $(gen_python_base_path),$(all_protos)))) $(addsuffix _pb2.py,$(basename $(addprefix $(gen_python_base_path),$(all_protos))))
elixir: $(addsuffix .pb.ex,$(basename $(addprefix $(gen_elixir_base_path),$(all_protos))))
doc: doc/index.html

# Python

$(gen_python_base_path)messages/%_pb2_grpc.py: ;

$(gen_python_base_path)%_pb2.py: protos/%.proto
	mkdir -p $(gen_python_base_path)
	mkdir -p $(gen_python_base_path)$(dir $*)
	python -m grpc_tools.protoc \
		-Iprotos \
		--python_out=$(gen_python_base_path) \
		$<

$(gen_python_base_path)%_pb2_grpc.py: protos/%.proto
	mkdir -p $(gen_python_base_path)
	mkdir -p $(gen_python_base_path)$(dir $*)
	python -m grpc_tools.protoc \
		-Iprotos \
		--grpc_python_out=$(gen_python_base_path) \
		$<

# Elixir

$(gen_elixir_base_path)messages/%.pb.ex: protos/messages/%.proto
	mkdir -p $(gen_elixir_base_path)$(dir $*)
	protoc -Iprotos --elixir_out=$(gen_elixir_base_path) $<

$(gen_elixir_base_path)%.pb.ex: protos/%.proto
	mkdir -p $(gen_elixir_base_path)
	mkdir -p $(gen_elixir_base_path)$(dir $*)
	protoc -Iprotos --elixir_out=plugins=grpc:$(gen_elixir_base_path) $<

# Document

doc/index.html:
	mkdir -p doc
	docker run --rm \
		-v $(workdir)/doc:/out \
		-v $(workdir)/protos:/protos \
		-v $(workdir)/protos/messages:/protos/messages \
		pseudomuto/protoc-gen-doc --doc_opt=html,index.html protos/*.proto protos/messages/*.proto

# Utils =====

clean:
	rm -rf gen
	rm -rf doc
