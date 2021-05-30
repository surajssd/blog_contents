---
author: "Suraj Deshmukh"
date: "2021-05-30T09:40:00+05:30"
title: "How to import 'any' Kubernetes package into your project?"
description: ""
draft: false
categories: ["kubernetes", "golang"]
tags: ["kubernetes", "golang"]
images:
- src: "/post/2021/05/k8s-import/gok8s.jpg"
  alt: "Golang and Kubernetes"
---

The client libraries that Kubernetes ships are meant to be imported, and you definitely don't need this post explaining how to import them in your Golang based project. A simple `go get ...` should do the trick. But, what about the packages that are not meant to be imported? Or the ones that cannot be imported because of _"technical reasons"_ ? Could you simply add them to your import statements in the `.go` file, and the `go` binary will do the right thing when you build the code? Well, let's find that out!

## Usecase

I have a project, and in it, the imported packages look like this:

```go
import (
	"crypto/x509"
	"fmt"
	"io/ioutil"
	"log"
	"path/filepath"

	"github.com/spf13/cobra"
	"k8s.io/client-go/util/cert"
	"k8s.io/client-go/util/keyutil"
	"k8s.io/kubernetes/test/utils"
)
```

[source](https://github.com/surajssd/self-signed-cert/blob/61a5c44ca2f4d6d951b361e1f271bd13ce355f9d/main.go#L3-L14)

So it consists of a couple of inbuilt packages, and then the CLI library [Cobra](https://github.com/spf13/cobra), a couple of [client-go](https://github.com/kubernetes/client-go) packages. The only out of the ordinary thing is the `k8s.io/kubernetes/test/utils` package.

## Importing

Let us tidy up the dependencies before building the code:

```
$ go get github.com/spf13/cobra \
>        k8s.io/client-go/util/cert \
>        k8s.io/client-go/util/keyutil \
>        k8s.io/kubernetes/test/utils
go: downloading k8s.io/client-go v1.5.2
go: downloading github.com/spf13/cobra v1.1.3
go: downloading k8s.io/kubernetes v1.21.1
go: downloading k8s.io/client-go v0.21.1
go get: k8s.io/kubernetes@v1.15.0-alpha.0 updating to
        k8s.io/kubernetes@v1.21.1 requires
        k8s.io/api@v0.0.0: reading k8s.io/api/go.mod at revision v0.0.0: unknown revision v0.0.0
```

Now, this is a weird error:

```
k8s.io/api@v0.0.0: reading k8s.io/api/go.mod at revision v0.0.0: unknown revision v0.0.0
```

## tl;dr Give me the solution

Save the following bash script in `download-deps.sh`:

```bash
#!/bin/bash

VERSION=${1#"v"}
if [ -z "$VERSION" ]; then
  echo "Please specify the Kubernetes version: e.g."
  echo "./download-deps.sh v1.21.0"
  exit 1
fi

set -euo pipefail

# Find out all the replaced imports, make a list of them.
MODS=($(
  curl -sS "https://raw.githubusercontent.com/kubernetes/kubernetes/v${VERSION}/go.mod" |
    sed -n 's|.*k8s.io/\(.*\) => ./staging/src/k8s.io/.*|k8s.io/\1|p'
))

# Now add those similar replace statements in the local go.mod file, but first find the version that
# the Kubernetes is using for them.
for MOD in "${MODS[@]}"; do
  V=$(
    go mod download -json "${MOD}@kubernetes-${VERSION}" |
      sed -n 's|.*"Version": "\(.*\)".*|\1|p'
  )

  go mod edit "-replace=${MOD}=${MOD}@${V}"
done

go get "k8s.io/kubernetes@v${VERSION}"
go mod download
```

Make the script usable:

```bash
chmod u+x download-deps.sh
```

Use the following script. It will update the `go.mod` file with the required dependencies:

```consle
$ ./download-deps.sh v1.21.0
go: downloading k8s.io/kubernetes v1.21.0
go get: added k8s.io/kubernetes v1.21.0
```

Now you can build your code! Keep reading further to understand why this happens.

> Kudos 👏 to [Andy Bursavich](https://github.com/abursavich) for writing the aforementioned script. I took the script from [this comment](https://github.com/kubernetes/kubernetes/issues/79384#issuecomment-521493597) and made minor modifications.

## Reasoning

The error `k8s.io/api@v0.0.0: reading k8s.io/api/go.mod at revision v0.0.0: unknown revision v0.0.0` is caused because, in Kubernetes's [`go.mod`](https://github.com/kubernetes/kubernetes/blob/e6136c0303028d68cac67290d94a60cec167ccdf/go.mod#L109-L120), you will find the following snippet:

```yaml
require (
...
	k8s.io/api v0.0.0
	k8s.io/apiextensions-apiserver v0.0.0
	k8s.io/apimachinery v0.0.0
	k8s.io/apiserver v0.0.0
...
)

replace (
...
	k8s.io/api => ./staging/src/k8s.io/api
	k8s.io/apiextensions-apiserver => ./staging/src/k8s.io/apiextensions-apiserver
	k8s.io/apimachinery => ./staging/src/k8s.io/apimachinery
	k8s.io/apiserver => ./staging/src/k8s.io/apiserver
...
)
```

In the Kubernetes repository, the packages listed under `require` directive are tagged with a pseudo-version `v0.0.0` but then are replaced with a local code in the [`staging`](https://github.com/kubernetes/kubernetes/tree/e8760b95bb0a0dfb5c184fd4e5ab95da3650a040/staging) directory. Now `replace` directive works fine when building Kubernetes itself but won't work when someone is importing it. The Golang documentation says the following about `replace` directive:

> `replace` directives only apply in the main module's go.mod file and are ignored in other modules.

[source](https://golang.org/ref/mod#go-mod-file-replace)

Generally, the pseudo-version has a format `v0.0.0-Time-commit_id`, but in this case, it practically is a dead end. Why is Kubernetes doing such a thing in their project? Why not tag with an actual pseudo-version format? Well, because the code is available locally. And the directories in the `staging` folder are published as standalone projects for folks to use later on.

So the net effect is that I am trying to import code using `go get`, but it is tagged with a pseudo-version `v0.0.0` and hence `go get` fails. The solution to this problem is to find the correct versions of those dependencies yourself and add them to your repo's `go.mod` under `replace` directive.

This is precisely what the script is doing.

## Final Go Mod

So in our project, the `go.mod` looks like this from the successful imports before running the script:

```yaml
module foobar

go 1.16

require (
        github.com/spf13/cobra v1.1.3 // indirect
        k8s.io/client-go v0.21.1 // indirect
)
```

After running the script, this is how it looks like:

```yaml
module foobar

go 1.16

require (
        github.com/spf13/cobra v1.1.3 // indirect
        k8s.io/client-go v0.21.1 // indirect
        k8s.io/kubernetes v1.21.0 // indirect
)

replace k8s.io/api => k8s.io/api v0.21.0
replace k8s.io/apiextensions-apiserver => k8s.io/apiextensions-apiserver v0.21.0
replace k8s.io/apimachinery => k8s.io/apimachinery v0.21.1-rc.0
replace k8s.io/apiserver => k8s.io/apiserver v0.21.0
...
```
