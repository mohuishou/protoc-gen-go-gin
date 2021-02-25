package main

import (
	"context"

	"github.com/gin-gonic/gin"
	"github.com/mohuishou/protoc-gen-go-gin/example/testproto"
	"github.com/pkg/errors"
)

type service struct {
}

func (s service) CreateArticle(ctx context.Context, article *testproto.Article) (*testproto.Empty, error) {
	if article.AuthorId < 1 {
		return nil, errors.Errorf("author id must > 0")
	}
	return nil, nil
}

func (s service) GetArticles(ctx context.Context, req *testproto.GetArticlesReq) (*testproto.GetArticlesResp, error) {
	if req.AuthorId < 0 {
		return nil, errors.Errorf("author id must >= 0")
	}
	return &testproto.GetArticlesResp{
		Total: 1,
		Articles: []*testproto.Article{
			{
				Title:    "test article: " + req.Title,
				Content:  "test",
				AuthorId: 1,
			},
		},
	}, nil
}

func main() {
	e := gin.Default()
	testproto.RegisterBlogServiceHTTPServer(e, &service{})
	e.Run()
}
