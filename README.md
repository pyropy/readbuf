Build:

`go build`

Usage:

```
NAME:
   readbuf read - Read compressed lz4 protobuf and print it to stdout

USAGE:
   readbuf read [command options] [arguments...]

OPTIONS:
   --path value  Path or URL to compressed lz4 file
   --type value  One of: block, tx, dex
   --help, -h    show help
```

Example usage with URL:

```
readbuf read --type block --path http://localhost:8080/eth.broadcasted/000017976000/000017976338_0xe66f8e385fe9ad89e9e8c2c80a23da6e8994913a0f726485f4ae1b5547ecef3c_19a16bb6c00a7e9ab79ddfb676dfdaa3bf647534916c3bd7692b0d8d37a109df.block.lz4
```

Example usage with local file:

`readbuf read --type block --path block.lz4`
