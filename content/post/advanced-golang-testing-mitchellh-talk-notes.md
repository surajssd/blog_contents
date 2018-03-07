+++
author = "Suraj Deshmukh"
title = "Notes on talk - Advanced testing in golang by Mitchell Hashimoto"
date = "2018-03-07T02:21:49+05:30"
description = "This talk has really great takeaways which are worth considering while writing your tests"
categories = ["golang", "programming"]
tags = ["golang", "programming"]
+++

## Test Fixtures

- "go test" sets pwd as package directory

## Test Helpers

- should never return an error they should access to the `*testing.T` object
- call `t.Helper()` in the beginning (works only for go1.9+)
- for things reqiuiring clean up return closures

## Configurability

- Unconfigurable behavior is often a point of difficulty for tests. e.g. ports, timeouts, paths.
- Over-parameterize structs to allow tests to fine-tune their behavior
- It's ok to make these configs unexported so only tests can set them.

## Slides

<script async class="speakerdeck-embed" data-id="02b292ed8f7f4edca8b616cba2dc7cd4" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

## Video

<center>
<iframe width="595" height="485" src="https://www.youtube.com/embed/8hQG7QlcLBk"
frameborder="0" style="border:1px solid #CCC; border-width:1px;
margin-bottom:5px; max-width: 100%;" allowfullscreen></iframe>
<div style="margin-bottom:5px"> <strong>
<a href="//youtu.be/8hQG7QlcLBk"
title="GopherCon 2017: Mitchell Hashimoto - Advanced Testing with Go"
target="_blank">GopherCon 2017: Mitchell Hashimoto - Advanced Testing with Go</a>
</strong> by <strong><a target="_blank"
href="https://twitter.com/mitchellh">Mitchell Hashimoto</a></strong>
</div>
</center>
