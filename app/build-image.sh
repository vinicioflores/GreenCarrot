#!/bin/sh

docker build -t viniciof1211/green-carrot-exec-flow .

docker tag viniciof1211/green-carrot-exec-flow  viniciof1211/green-carrot-exec-flow

docker push viniciof1211/green-carrot-exec-flow

docker run -p 4000:8080 viniciof1211/green-carrot-exec-flow