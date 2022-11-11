package main

import (
	"context"
	"net"

	"github.com/inverse-inc/go-radius"
)

type RadiusProxy struct {
}

func (rp *RadiusProxy) ServeRADIUS(w radius.ResponseWriter, r *radius.Request) {
	p, err := radius.Exchange(r.Context(), r.Packet, "localhost:11812")
	if err == nil {
		p.Authenticator = r.Packet.Authenticator
		w.Write(p)
	}
}

func (rp *RadiusProxy) RADIUSSecret(ctx context.Context, remoteAddr net.Addr, raw []byte) ([]byte, context.Context, error) {
	/*
		srcIpAddr := remoteAddr.(*net.UDPAddr).IP.String()
		var nasIpAddr string
		var err error
		var macStr string
		err = checkPacket(raw)
		if err != nil {
			logError(h.LoggerCtx, "RADIUSSecret: "+err.Error())
			return nil, nil, err
		}

		attrs, err := radius.ParseAttributes(raw[20:])
		if err != nil {
			logError(h.LoggerCtx, "RADIUSSecret: "+err.Error())
			return nil, nil, err
		}

		return nil, context.Background(), nil
	*/
	return []byte("testing123"), ctx, nil
}

func (rp *RadiusProxy) PacketServer() *radius.PacketServer {
	return &radius.PacketServer{
		Handler:      rp,
		SecretSource: rp,
	}
}

func main() {
	proxy := &RadiusProxy{}
	addr, err := net.ResolveUDPAddr("udp4", "0.0.0.0:1812")
	if err != nil {
		panic(err)
	}

	pc, err := net.ListenUDP("udp4", addr)
	if err != nil {
		panic(err)
	}

	server := proxy.PacketServer()
	server.Serve(pc)
	if err := server.Serve(pc); err != radius.ErrServerShutdown {
		panic(err)
	}
}
