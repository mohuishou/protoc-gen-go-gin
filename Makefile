gen_example:
	go install
	protoc -I ./example \
	--openapiv2_out ./example --openapiv2_opt logtostderr=true \
	--openapiv2_opt json_names_for_fields=false \
	--go_out ./example --go_opt=paths=source_relative \
	--go-gin_out ./example --go-gin_opt=paths=source_relative \
	example/testproto/*.proto
	protoc-go-inject-tag -input=./example/testproto/test.pb.go