
flutter_sdk_out_path = ./dart/
typescript_sdk_out_path = ./typescript/
kotlin_out_path = ./kotlin/

flutter_sdk_models_path = ../flutter-sdk/lib/src/domain/models
webchat_sdk_models_path = ../web-sdk/src/domain/models

proto: proto_go proto_ts proto_dart proto_kotlin symlinks

symlinks:
	ln -sfn ../../../../../proto/dart/events $(flutter_sdk_models_path)/events
	ln -sfn ../../../../proto/typescript/events $(webchat_sdk_models_path)/events
	ln -sfn ../../../../proto/typescript/google $(webchat_sdk_models_path)/google
.PHONY: symlinks

proto_go:
	mkdir -p golang
	protoc --go_out=. --go_opt=paths=import,module=github.com/yalochat/chat-sdk/proto/v2 \
		   --plugin protoc-gen-go-vtproto=`which protoc-gen-go-vtproto` \
		   --go-vtproto_out=. \
		   --go-vtproto_opt=features=marshal+unmarshal+size,paths=import,module=github.com/yalochat/chat-sdk/proto/v2 \
		   `find events -name '*.proto' -print | sort`
.PHONY: proto_go

proto_ts:
	mkdir -p $(typescript_sdk_out_path)
	protoc --plugin=./node_modules/.bin/protoc-gen-ts_proto --ts_proto_opt=enumsAsLiterals=true --ts_proto_out=$(typescript_sdk_out_path) `find events -name '*.proto' -print | sort`
.PHONY: proto_ts

proto_dart:
	mkdir -p $(flutter_sdk_out_path)
	protoc --dart_out=$(flutter_sdk_out_path) `find events -name '*.proto' -print | sort`
.PHONY: proto_dart

# Android SDK: generate Java sources from the proto. The full runtime is
# required because the wire format is proto3 JSON and JsonFormat needs the
# descriptors that the lite runtime strips. The :sdk module reads this output
# directly as an extra source directory, so it must stay committed.
proto_kotlin:
	mkdir -p $(kotlin_out_path)
	protoc --java_out=$(kotlin_out_path) \
		   --kotlin_out=$(kotlin_out_path) \
		   `find events -name '*.proto' -print | sort`
.PHONY: proto_kotlin
