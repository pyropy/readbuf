package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/pierrec/lz4"
	evm_messages "github.com/pyropy/readbuf/evm/messages"
	"github.com/urfave/cli/v2"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/proto"
)

func main() {
	local := []*cli.Command{
		debuf,
	}

	app := cli.App{
		Name:     "readbuf",
		Commands: local,
	}

	if err := app.Run(os.Args); err != nil {
		log.Fatal(err)
		return
	}

}

func read(path string) (decompressed []byte, err error) {
	var data io.ReadCloser

	if isUrl(path) {
		data, err = streamFile(path)
		if err != nil {
			return nil, err
		}
	} else {
		data, err = readFile(path)
		if err != nil {
			return nil, err
		}
	}

	defer data.Close()

	decompressed, err = io.ReadAll(lz4.NewReader(data))
	if err != nil {
		return nil, err
	}

	return decompressed, nil
}

func streamFile(url string) (io.ReadCloser, error) {
	r, err := http.Get(url)
	if err != nil {
		return nil, err
	}

	return r.Body, nil
}

func readFile(path string) (io.ReadCloser, error) {
	data, err := os.Open(path)
	if err != nil {
		return nil, err
	}

	return data, nil
}

var debuf = &cli.Command{
	Name:  "read",
	Usage: "Read compressed lz4 protobuf and print it to stdout",
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:     "path",
			Usage:    "Path or URL to compressed lz4 file",
			Required: true,
		},
		&cli.StringFlag{
			Name:     "type",
			Usage:    "One of: block, tx, dex",
			Required: true,
		},
	},
	Action: func(ctx *cli.Context) error {
		t := ctx.String("type")
		path := ctx.String("path")

		data, err := read(path)
		if err != nil {
			return err
		}

		var msg string

		switch t {
		case "block":
			msg, err = readBlock(data)
		case "tx":
			msg, err = readTx(data)
		case "dex":
			msg, err = readDexTx(data)
		}

		if err != nil {
			return err
		}

		fmt.Printf(msg)
		return nil
	},
}

func readBlock(data []byte) (string, error) {
	var msg evm_messages.BlockMessage

	err := proto.Unmarshal(data, &msg)
	if err != nil {
		return "", err
	}

	formatted := protojson.Format(&msg)
	return formatted, nil
}

func readTx(data []byte) (string, error) {
	var msg evm_messages.ParsedAbiTransaction

	err := proto.Unmarshal(data, &msg)
	if err != nil {
		return "", err
	}

	formatted := protojson.Format(&msg)
	return formatted, nil
}

func readDexTx(data []byte) (string, error) {
	var msg evm_messages.DexBlockMessage

	err := proto.Unmarshal(data, &msg)
	if err != nil {
		return "", err
	}

	formatted := protojson.Format(&msg)
	return formatted, nil
}

func isUrl(path string) bool {
	return strings.Contains(path, "http://") || strings.Contains(path, "https://")
}
