+++
author = "Suraj Deshmukh"
title = "Cobra and Persistentflags gotchas"
description = "How wrong usage of persistent flags can burn you"
date = "2019-01-04T01:00:51+05:30"
categories = ["golang"]
tags = ["cobra", "notes", "golang", "programming"]
+++

If you are using [cobra](https://github.com/spf13/cobra) cmd line library for golang applications and it's `PersistentFlags` and if you have a use case where you are adding same kind of flag in multiple places. You might burn your fingers in that case, if you keep adding it in multiple sub-commands without giving it a second thought. To understand what is really happening and why it is happening follow along.

All the code referenced here can be found here [https://github.com/surajssd/cobrademo](https://github.com/surajssd/cobrademo).

![](/images/cobra-persistent-flag/cobra.png "")

The cmd line tool built with cobra has following structure. The main tool is called `cobrademo`. And the sub-commands are `alpha` and `num`. Sub-command `num` has one more sub-command called `one`.

```bash
cobrademo
├── alpha
└── num
    └── one
```

Now I want a persistent flag `--config` to be availabe under sub-command `one` and `alpha` both. So I created a func that allows me to add this flag under any command, which looked like following:

```go
func addConfig(cmd *cobra.Command) {
	// add config flag
	cmd.PersistentFlags().String(
		"config",
		os.ExpandEnv("$HOME/.config"),
		"Path to config file")
	viper.BindPFlag("config", cmd.PersistentFlags().Lookup("config"))
}
```

Above code is [here](https://github.com/surajssd/cobrademo/blob/26122e97d841bb1545d19bac6ce11110413803ec/cmd/root.go#L29-L36).

Now this is called from [`one.go`](https://github.com/surajssd/cobrademo/blob/26122e97d841bb1545d19bac6ce11110413803ec/cmd/one.go#L18) and [`alpha.go`](https://github.com/surajssd/cobrademo/blob/26122e97d841bb1545d19bac6ce11110413803ec/cmd/alpha.go#L18) to add the flag under those sub-command. 

Now the command structure for `alpha` sub-command looks like following:

```bash
$ go run main.go alpha -h
All the alphabet related commands

Usage:
  cobrademo alpha [flags]

Flags:
      --config string   Path to config file (default "/home/hummer/.config")
  -h, --help            help for alpha

```

For sub-command `one` it looks like following:

```bash
$ go run main.go num -h
All the numeric related commands

Usage:
  cobrademo num [command]

Available Commands:
  one         first subcommand in numerics

Flags:
  -h, --help   help for num

Use "cobrademo num [command] --help" for more information about a command.
```
```bash
$ go run main.go num one -h
first subcommand in numerics

Usage:
  cobrademo num one [flags]

Flags:
      --config string   Path to config file (default "/home/hummer/.config")
  -h, --help            help for one
```


But if you look at the functionality it does not work as expected.

```bash
$ go run main.go num one --config=foobar
inside one, config value:  foobar

$ go run main.go alpha --config=foobar
inside alpha, config value:  /home/hummer/.config
```

If you see the output of both the commands it is different. While it should have been same i.e. `foobar`. What made it work in case of sub-command `one` and it did not work in case of sub-command `alpha`?

Now we are registering a persistent flag twice once for sub-command [`one`](https://github.com/surajssd/cobrademo/blob/26122e97d841bb1545d19bac6ce11110413803ec/cmd/one.go#L16-L19) and again for [`alpha`](https://github.com/surajssd/cobrademo/blob/26122e97d841bb1545d19bac6ce11110413803ec/cmd/alpha.go#L16-L19). And these calls happen from the `init` func of those files. If you look at the order of the evaluation of those `init` functions then it happens in alphabetical order.

```bash
$ tree cmd/
cmd/
├── alpha.go
├── num.go
├── one.go
└── root.go
```


Hence the `init` func of `alpha` is called first and the flag `config` is registered there first and again it is registered for `one`. So the final flag is just registered for `one`. Hence the functionality works correctly for `one` and not for `alpha`.

So the right way to work with persistent flags is to register them only once. If any particular sub-command tree needs that flag then only register at it's root. In our case most of the sub-commands will need it, so the right way to use it is to add it to the [`rootCmd`](https://github.com/surajssd/cobrademo/blob/ab3fe4d7ecec26ca5c02cffa861941708f89a5de/cmd/root.go#L10-L13).

In above code I removed the function `addConfig` and all it's references(see the changes [here](https://github.com/surajssd/cobrademo/commit/ab3fe4d7ecec26ca5c02cffa861941708f89a5de)). And added following code snippet to the `init` func of `root.go`.

```go
	// add config flag
	rootCmd.PersistentFlags().String(
		"config",
		os.ExpandEnv("$HOME/.config"),
		"Path to config file")
	viper.BindPFlag("config", rootCmd.PersistentFlags().Lookup("config"))
```

And now after running the code again with above changes it works absolutely fine:

```bash
$ go run main.go num one --config=foobar
inside one, config value:  foobar

$ go run main.go alpha --config=foobar
inside alpha, config value:  foobar
```

There are other cobra gotchas that exist but then that is for another post.
