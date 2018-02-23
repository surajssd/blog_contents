+++
author = "Suraj Deshmukh"
title = "Methods that satisfy interfaces in golang"
description = "What receiver type methods satisfy which interface, can be understood here."
date = "2018-02-23T08:00:51+05:30"
categories = ["golang", "programming"]
tags = ["golang", "programming"]
+++

## Pointer receiver

For a struct `User` with a method `Work` with pointer receiver.

```go
type User struct {
    Name   string
    Period int
}

func (u *User) Work() {
    fmt.Println(u.Name, "has worked for", u.Period, "hrs.")
}

func main() {
    uval := User{"UserVal", 5}
    uval.Work()

    pval := &User{"UserPtr", 6}
    pval.Work()
}
```

See on [go playground](https://play.golang.org/p/PDsMlrd3QXV).

output:

```bash
UserVal has worked for 5 hrs.
UserPtr has worked for 6 hrs.
```

If we call this method on **value** type object `uval` it works, and obviously it works with **pointer** type object `pval`.

## Value receiver

Now we change the method receiver from pointer to value.

```go
type User struct {
    Name   string
    Period int
}

func (u User) Work() {
    fmt.Println(u.Name, "has worked for", u.Period, "hrs.")
}

func main() {
    uval := User{"UserVal", 5}
    uval.Work()

    pval := &User{"UserPtr", 6}
    pval.Work()
}
```

See on [go playground](https://play.golang.org/p/z7Q-B9PuzV2).

output:

```bash
UserVal has worked for 5 hrs.
UserPtr has worked for 6 hrs.
```

So this also worked on both **value** type object `uval` and with **pointer** type object `pval`.

## Interface and pointer receiver

Lets try to add interface in the mix and see what happens, so adding interface `Worker` to pointer receiver method:

```go
type User struct {
    Name   string
    Period int
}

type Worker interface {
    Work()
}

func (u *User) Work() {
    fmt.Println(u.Name, "has worked for", u.Period, "hrs.")
}

func main() {
    uval := User{"UserVal", 5}
    DoWork(uval)

    pval := &User{"UserPtr", 6}
    DoWork(pval)
}

func DoWork(w Worker) {
    w.Work()
}
```

See on [go playground](https://play.golang.org/p/shQ4PT66VaY).

output:

```bash
# command-line-arguments
tmp/main.go:20:8: cannot use uval (type User) as type Worker in argument to DoWork:
        User does not implement Worker (Work method has pointer receiver)
```

So **pointer** type object `pval` implements interface `Worker`, but **value** type object `uval` does not. Since the error clearly says

```bash
User does not implement Worker (Work method has pointer receiver)
```

To understand why this above code fails, you need to understand the concept of method sets. [Golang spec](https://golang.org/ref/spec#Method_sets) defines **Method sets** as:

>The method set of any other type T consists of all methods declared with receiver type T.

and

>The method set of the corresponding pointer type *T is the set of all methods declared with receiver *T or T (that is, it also contains the method set of T).

finally

>The method set of a type determines the interfaces that the type implements and the methods that can be called using a receiver of that type.

In above example the method with pointer receiver is not in method set of **value** type object `uval`.

## Interface and value receiver

Now lets try the same inteface but this time with value receiver:

```go
type User struct {
    Name   string
    Period int
}

type Worker interface {
    Work()
}

func (u User) Work() {
    fmt.Println(u.Name, "has worked for", u.Period, "hrs.")
}

func main() {
    uval := User{"UserVal", 5}
    DoWork(uval)

    pval := &User{"UserPtr", 6}
    DoWork(pval)
}

func DoWork(w Worker) {
    w.Work()
}
```

See on [go playground](https://play.golang.org/p/aW6kXdeNaqN).

output:

```bash
UserVal has worked for 5 hrs.
UserPtr has worked for 6 hrs.
```

Meanwhile the method with value receiver worked for both type of objects **pointer** type object `pval` and **value** type object `uval`.

So here is a table which charts this behavior:

   scenario              |   object value  |  object pointer
------------------------ |-----------------|-----------------
pointer method           |       yes       |     yes
value method             |       yes       |     yes
interface pointer method |       no        |     yes
interface value method   |       yes       |     yes


More on the case of why code compilation fails or compiler complains about **value** type object `uval` not implementing the interface `Worker`.


## References

- [Method sets in golang spec](https://golang.org/ref/spec#Method_sets)
- [Methods, Interfaces and Embedded Types in Go](https://www.ardanlabs.com/blog/2014/05/methods-interfaces-and-embedded-types.html)