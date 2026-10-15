
flutter_sdk_out_path = ./dart/
typescript_sdk_out_path = ./typescript/
kotlin_out_path = ./kotlin/
swift_out_path = ./swift/

flutter_sdk_models_path = ../flutter-sdk/lib/src/domain/models
webchat_sdk_models_path = ../web-sdk/src/domain/models

proto: proto_go proto_ts proto_dart proto_kotlin proto_swift symlinks

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

# Android SDK: generate Kotlin sources with Wire, so the SDK does not ship the
# protobuf runtime and clash with the one apps get from Firebase. The :sdk
# module reads this output directly as an extra source directory, so it must
# stay committed. wire_version has to match `wire` in
# android-sdk/gradle/libs.versions.toml.
#
# Wire always turns google.protobuf.Timestamp into java.time.Instant, which
# would make every app turn on desugaring. So a copy of the protos is generated
# instead, with the timestamp swapped for the stand-in in wire/timestamp.proto.
wire_version = 5.5.1
wire_jar = .wire/wire-compiler-$(wire_version).jar
wire_build = .wire/events

$(wire_jar):
	mkdir -p .wire
	curl -fsSL -o $@ https://repo1.maven.org/maven2/com/squareup/wire/wire-compiler/$(wire_version)/wire-compiler-$(wire_version)-jar-with-dependencies.jar

proto_kotlin: $(wire_jar)
	rm -rf $(wire_build) $(kotlin_out_path)
	mkdir -p $(wire_build) $(kotlin_out_path)
	cp -R events/. $(wire_build)/
	cp wire/timestamp.proto $(wire_build)/
	find $(wire_build) -name '*.proto' -exec sed -i.bak \
		-e 's|"google/protobuf/timestamp.proto"|"timestamp.proto"|' \
		-e 's|google\.protobuf\.Timestamp|yalo.wire.Timestamp|g' {} \;
	java -jar $(wire_jar) --proto_path=$(wire_build) --kotlin_out=$(kotlin_out_path) > /dev/null
	! grep -rq "Instant" $(kotlin_out_path)
.PHONY: proto_kotlin

# iOS SDK: the root Package.swift reads this output as the YaloChatProto
# target, so it must stay committed. Package visibility keeps the types
# usable inside the SDK package without exposing them to integrators.
proto_swift:
	mkdir -p $(swift_out_path)
	protoc --swift_out=$(swift_out_path) \
		   --swift_opt=Visibility=Package \
		   `find events -name '*.proto' -print | sort`
.PHONY: proto_swift
