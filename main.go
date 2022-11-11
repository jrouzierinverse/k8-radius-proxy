package main

import (
	"time"

	"github.com/inverse-inc/go-radius"
)

type RadiusProxy struct {
}

func (rp *RadiusProxy) ServerRADIUS(w radius.ResponseWriter, r *radius.Request) {
}

func main() {
	for {
		time.Sleep(1 * time.Second)
	}
}
