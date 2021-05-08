package main

import (
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/mohuishou/protoc-gen-go-gin/example/api/product/app/ecode"
	v1 "github.com/mohuishou/protoc-gen-go-gin/example/api/product/app/v1"
)

type service struct {
}

func (s service) CreateArticle(ctx context.Context, article *v1.Article) (*v1.Article, error) {
	if article.AuthorId < 1 {
		return nil, ecode.Errorf(http.StatusBadRequest, 400, "author id must > 0")
	}
	return article, nil
}

func (s service) GetArticles(ctx context.Context, req *v1.GetArticlesReq) (*v1.GetArticlesResp, error) {
	if req.AuthorId < 0 {
		return nil, ecode.Errorf(http.StatusBadRequest, 400, "author id must >= 0")
	}
	return &v1.GetArticlesResp{
		Total: 1,
		Articles: []*v1.Article{
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
	v1.RegisterBlogServiceHTTPServer(e, &service{})
	e.Run()
}
