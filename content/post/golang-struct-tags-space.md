+++
author = "Suraj Deshmukh"
title = "Golang struct tags gotchas"
description = "Struct tags can give you problems you didn't see coming ;-)"
date = "2018-08-12T01:00:51+05:30"
categories = ["golang"]
tags = ["golang", "notes"]
+++

In golang while using struct tag, the spaces make a lot of difference. For example look at the following code.

```go
type PodStatus struct {
	Status string `json: ",status"`
}
```

If you run [`go vet`](https://golang.org/cmd/vet/) on this piece of code you will get following error:

```bash
$ go vet types.go 
# command-line-arguments
./types.go:28: struct field tag `json: ",status"` 
not compatible with reflect.StructTag.Get: bad syntax for struct tag value
```

Now this does not tell us what is wrong with the struct tag, `json: ",status"`. The problem with this struct tag is that the extra space can be interpreted as delimiter so provide key-value pair without space.

So if the struct changes from:

```go
`json: ",status"`
```

to

```go
`json:",status"`
```

So the change is just the space after `json:`, now we don't see the error.

More information about the struct tags can be found in this elaborated blog post named: [*Tags in Golang*](https://medium.com/golangspec/tags-in-golang-3e5db0b8ef3e).
