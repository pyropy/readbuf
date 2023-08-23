GITHUB := github.com/bitquery/streaming_processor

SUBMODULE_EVM_SRC_DIR := evm
SUBMODULE_EVM_DEST_DIR := evm/messages
SUBMODULE_EVM_PACKAGE := evm_messages
SUBMODULE_EVM_FILES := $(shell find ./submodules/streaming_protobuf/$(SUBMODULE_EVM_SRC_DIR) -type f -name '*.proto')

SUBMODULE_BC_SRC_DIR := blockchain
SUBMODULE_BC_DEST_DIR := blockchain/messages
SUBMODULE_BC_PACKAGE := blockchain_messages
SUBMODULE_BC_FILES := $(shell find ./submodules/streaming_protobuf/$(SUBMODULE_BC_SRC_DIR) -type f -name '*.proto')

#GENERATE_TEMPLATE := "--go_opt=\"M$(SUBMODULE_EVM_SRC_DIR)/%s=$(SUBMODULE_EVM_DEST_DIR);$(SUBMODULE_EVM_PACKAGE)\""
#IMPORT_TEMPLATE := "--go_opt=\"M$(SUBMODULE_EVM_SRC_DIR)/%s=$(GITHUB)/$(SUBMODULE_EVM_DEST_DIR);$(SUBMODULE_EVM_PACKAGE)\""


compile:
	# compile protos from submodules/streaming_protobuf
	protoc \
	-I=./submodules/streaming_protobuf \
	--go_out=. \
	--go_opt="Mevm/block_message.proto=$(SUBMODULE_EVM_DEST_DIR);$(SUBMODULE_EVM_PACKAGE)" \
	--go_opt="Mevm/dex_block_message.proto=$(SUBMODULE_EVM_DEST_DIR);$(SUBMODULE_EVM_PACKAGE)" \
	--go_opt="Mevm/parsed_abi_block_message.proto=$(SUBMODULE_EVM_DEST_DIR);$(SUBMODULE_EVM_PACKAGE)" \
	--go_opt="Mevm/token_block_message.proto=$(SUBMODULE_EVM_DEST_DIR);$(SUBMODULE_EVM_PACKAGE)" \
	--go_opt="Mblockchain/indexing.proto=$(SUBMODULE_BC_DEST_DIR);$(SUBMODULE_BC_PACKAGE)" \
	$(SUBMODULE_EVM_FILES) $(SUBMODULE_BC_FILES)

	# compile protos from this repo except for those in submodules and that must not compile docker-compose, schema directories
	protoc \
	-I=. \
	--go_out=. \
	--go_opt=paths=source_relative \
	--proto_path=./submodules/streaming_protobuf \
	--proto_path=./evm/archive \
	--go_opt="Mevm/block_message.proto=$(GITHUB)/$(SUBMODULE_EVM_DEST_DIR);$(SUBMODULE_EVM_PACKAGE)" \
	--go_opt="Mevm/dex_block_message.proto=$(GITHUB)/$(SUBMODULE_EVM_DEST_DIR);$(SUBMODULE_EVM_PACKAGE)" \
	--go_opt="Mevm/parsed_abi_block_message.proto=$(GITHUB)/$(SUBMODULE_EVM_DEST_DIR);$(SUBMODULE_EVM_PACKAGE)" \
	--go_opt="Mevm/token_block_message.proto=$(GITHUB)/$(SUBMODULE_EVM_DEST_DIR);$(SUBMODULE_EVM_PACKAGE)" \
	--go_opt="Mblockchain/indexing.proto=$(GITHUB)/$(SUBMODULE_BC_DEST_DIR);$(SUBMODULE_BC_PACKAGE)" \
	--go_opt="Mevm/archive/tables.proto=$(GITHUB)/evm/archive;evm_archive" \
	$(shell find . -type d \( -path ./submodules -o -path ./docker-compose -o -path ./schema \) -prune -o -name '*.proto' -print)
