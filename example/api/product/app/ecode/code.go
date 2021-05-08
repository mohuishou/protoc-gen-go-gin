package ecode

import (
	"fmt"
)

type ecode struct {
	status int
	code   int
	msg    string
}

// Error for error
func (code ecode) Error() string {
	return fmt.Sprintf("WantCode: %d, msg: %s", code.code, code.msg)
}

// Code Code
func (code ecode) Code() int {
	return code.code
}

// Message Message
func (code ecode) Message() string {
	return code.msg
}

// HTTPCode HTTPCode
func (code ecode) HTTPCode() int {
	return code.status
}

// Errorf Errorf
func Errorf(status, code int, msg string, v ...interface{}) error {
	return &ecode{
		status: status,
		code:   code,
		msg:    fmt.Sprintf(msg, v...),
	}
}
