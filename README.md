# hosts Editor

A command line tool for editing "hosts" file.

## Installation

    > npm install -g hosts-edit

## Usage

Just take two parameters:

1. An IP address
1. A name for the address above

```
> hosts-edit 192.168.1.1 my-router
```

## Build to a executable file

### Install npm command line tool **pkg***

    > npm install -g pkg

### Generate executable file

    > bash build.sh

you can find those file in **build/Release/** directory.