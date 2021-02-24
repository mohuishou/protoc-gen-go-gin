type {{.ServiceType}}HTTPServer interface {
{{range .MethodSets}}
	{{.Name}}(context.Context, *{{.Request}}) (*{{.Reply}}, error)
{{end}}
}
func Register{{.ServiceType}}HTTPServer(r gin.IRouter, srv {{.ServiceType}}HTTPServer) {
	s := {{.ServiceType}}{
		server: srv,
		router:     r,
	}
	s.RegisterService()
}

type {{$.ServiceType}} struct{
	server {{$.ServiceType}}HTTPServer
	router gin.IRouter
}

// Resp 返回值
type {{$.ServiceType}}Resp struct {
	Code int          `json:"code"`
	Msg  string       `json:"msg"`
	Data interface{}  `json:"data"`
}

// errResp errResp
func (s *{{$.ServiceType}}) errResp(ctx *gin.Context, err error) {
	resp := {{$.ServiceType}}Resp{
		Code: -1,
		Msg:  "未知错误",
	}
	status := 500
	
	if err == nil {
		resp.Msg += ", err is nil"
		ctx.JSON(status, resp)
		return
	}

	type iCode interface{
		HTTPCode() int
		Message() string
		Code() int
	}

	var c iCode
	if errors.As(err, &c) {
		status = c.HTTPCode()
		resp.Code = c.Code()
		resp.Msg = c.Message()
	}

	_ = ctx.Error(err)

	ctx.JSON(status, resp)
}

func (s *{{$.ServiceType}}) paramsErrResp(ctx *gin.Context, err error){
	resp := {{$.ServiceType}}Resp{
		Code: 400,
		Msg:  "参数错误",
	}
	status := 400
	_ = ctx.Error(err)
	ctx.JSON(status, resp)
}



{{range .Methods}}
func (s *{{$.ServiceType}}) {{.Name}}_{{.Num}} (ctx *gin.Context) {
	var in {{.Request}}
{{if ne (len .Vars) 0}}
	if err := ctx.ShouldBindUri(&in); err != nil {
		s.paramsErrResp(ctx, err)
		return
	}
{{end}}
{{if eq .Method "GET" "DELETE" }}
	if err := ctx.ShouldBindQuery(&in); err != nil {
		s.paramsErrResp(ctx, err)
		return
	}
{{else if eq .Method "POST" "PUT" }}
	if err := ctx.ShouldBindJSON(&in); err != nil {
		s.paramsErrResp(ctx, err)
		return
	}
{{else}}
	if err := ctx.ShouldBind(&in); err != nil {
		s.paramsErrResp(ctx, err)
		return
	}
{{end}}
	md := metadata.New(nil)
	for k, v := range ctx.Request.Header {
		md.Set(k, v...)
	}
	newCtx := metadata.NewIncomingContext(ctx, md)
	out, err := s.server.({{$.ServiceType}}HTTPServer).{{.Name}}(newCtx, &in)
	if err != nil {
		s.errResp(ctx, err)
		return
	}
	ctx.JSON(200, {{$.ServiceType}}Resp{
		Code: 0,
		Msg:  "成功",
		Data: out,
	})
	return
}
{{end}}

func (s *{{$.ServiceType}}) RegisterService() {
{{range .Methods}}
		s.router.Handle("{{.Method}}", "{{.Path}}", s.{{.Name}}_{{.Num}})
{{end}}
}