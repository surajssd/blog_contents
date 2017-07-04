+++
author = "Suraj Deshmukh"
date = "2017-07-04T22:50:43+05:30"
title = "Clean Node setup"
categories = ["notes"]
tags = ["notes"]
description = "This will help in intalling node without sudo"
+++

Make sure you have `npm` installed.
```bash
$ sudo dnf -y install npm
Package npm-1:3.10.10-1.6.10.3.1.fc25.x86_64 is already installed, skipping.
Dependencies resolved.
Nothing to do.
Complete!
```

Taken from [this post](https://github.com/sindresorhus/guides/blob/master/npm-global-without-sudo.md).
```bash
mkdir "${HOME}/.npm-packages"
echo 'prefix=${HOME}/.npm-packages' | tee -a ~/.npmrc

echo '
#======================================
# npm related stuff

NPM_PACKAGES="${HOME}/.npm-packages"
PATH="$NPM_PACKAGES/bin:$PATH"

# Unset manpath so we can inherit from /etc/manpath via the `manpath` command
unset MANPATH # delete if you already modified MANPATH elsewhere in your config
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"
#======================================
' | tee -a ~/.bashrc
```


## Ref:

- [npm throws error without sudo](https://stackoverflow.com/questions/16151018/npm-throws-error-without-sudo/24404451#24404451) - Stack Overflow question
- [Install npm packages globally without sudo on macOS and Linux](https://github.com/sindresorhus/guides/blob/master/npm-global-without-sudo.md)
