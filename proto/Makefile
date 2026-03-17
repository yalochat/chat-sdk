
flutter_sdk_out_path = ../flutter-sdk/lib/src/domain/models/
typescript_sdk_out_path = ../web-sdk/src/domain/models/

proto: proto_go proto_ts proto_dart

proto_go:
	mkdir -p golang
	protoc --go_out=. --go_opt=paths=import,module=github.com/yalochat/chat-sdk/proto \
		   --plugin protoc-gen-go-vtproto=`which protoc-gen-go-vtproto` \
		   --go-vtproto_out=. \
		   --go-vtproto_opt=features=marshal+unmarshal+size,paths=import,module=github.com/yalochat/chat-sdk/proto \
		   `find events -name '*.proto' -print | sort`
.PHONY: proto_go

proto_ts:
	mkdir -p $(typescript_sdk_out_path)
	protoc --plugin=./node_modules/.bin/protoc-gen-ts_proto --ts_proto_out=$(typescript_sdk_out_path) `find events -name '*.proto' -print | sort`
.PHONY: proto_ts

proto_dart:
	mkdir -p $(flutter_sdk_out_path)
	protoc --dart_out=$(flutter_sdk_out_path) `find events -name '*.proto' -print | sort`
.PHONY: proto_dart
