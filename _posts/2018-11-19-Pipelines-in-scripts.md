---
layout: post
title: Adding Pipeline Support to Your Scripts!
date: 2018-11-18
categories: [powershell]
tags: [powershell,notifications,alerting]
---

You've probably used the pipeline 1,000 times and not though about _how_ exactly you can send the output of one command to another. It's actually, incredibly simple to do, and enables you to have a LOT of flexibility in your scripts!

## Pipeline overview

If you are just starting out in Powershell and stumbled across this blog post, I'd like to take a moment to explain just exactlty the Powershell Pipeline _is_, and how it _works_.

The pipeline is one of the most powerful parts of Powershell! A good analogy to use to give a visual representation of the pipeline. Think of it like a colored stack of lego blocks. Each part of the stack is an individual piece of the whole stack.

The pipeline character is the | (pipe), and pipeline _elements_ are the cmdlets you are running on each side of it.

When working with the pipeline it's important to remember the idea of _"Filter Left,Format Right"_. This means that you make your object (pipeline element) as small as possible at the very beginning of your pipeline, before sending it on to the next command, and finally, outputting it in whatever format you wish (note, this could be any of the _Format-*_ cmdlets, or writing to the screen or a file,etc.)

## Using the pipeline for discovery

The pipeline is one of, no probably _the_ best tool for discovering things inside of Powershell. Take this for example:

You wish to find all of the "stuff" attached to an object emitted by `Get-Process`

Run this in a console: `Get-Service | Get-Member`
The screen output you see contains useful information such as all the properties, and methods attached to the object, and also what Type of object it returns.

## Leveraging the pipeline in code

Ah, finally. With a bit of background out of the way, let's dig into the fun stuff, writing code to leverage the pipeline!

Consider the following `Param()` block declaration

```powershell
[cmdletBinding()]
Param(
    [Parameter(Mandatory,Position=0,ValueFromPipeline=$true)]
    [string]
    $Name
)
```

The above param block tells your script that the Name parameter accepts pipeline input. The caveat here is that `ValueFromPipeline` expects the pipeline input to be of the same _type_ as what it expects (string in this instance), or that it can be converted to the type that it expects.

For something like a script to work with computer names you may do something like this:

`Get-ADComputer randompc | YourFunction -Name $_.Name`

By using the pipeline, you access the current object's (`$_`) Name property in the pipeline, and it happily accepts it into Name parameter.

Another option is `ValueFromPipelineByPropertyName`, which like the first option, expects input of the same _type_, but also has the requirement that the object contain a property of the same _name_ as the parameter you wish to pass it too.

You can use a named expression to coerce your pipeline into working if the object you receive doesn't have the same name, but is of the same type. Here's an example (let's pretend name doesn't exist on Get-ADComputer, and use something else in its place)

`Get-ADComputer | Select-Object @{Name='Name';Expression={$_.DNSName}} | YourFunction`

That's all there is to adding pipeline support to your functions! Give it a try, and take your scripts to higher levels of functionality! Have questions or feedback? Use the links below to contact me. I'd love to hear from you!

