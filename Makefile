gen_example:
	go install
	protoc -I ./example/api \
	--openapiv2_out ./example/api --openapiv2_opt logtostderr=true \
	--openapiv2_opt json_names_for_fields=false \
	--go_out ./example/api --go_opt=paths=source_relative \
	--go-gin_out ./example/api --go-gin_opt=paths=source_relative \
	example/api/product/app/v1/v1.proto
	protoc-go-inject-tag -input=./example/api/product/app/v1/v1.pb.go