# Set a NeoPixel to a color specified in the environment, and blink it.

DOCKERHUB_ID:=ibmosquito
SERVICE_NAME:="neopixel-color"
SERVICE_VERSION:="1.0.0"
PATTERN_NAME:="pattern-neopixel-color"

# Optionally, set these variables in the shell environment
#   NEOPIXEL_COLOR
#   SECONDS_ON
#   SECONDS_OFF

# Leave blank for public DockerHub containers
# CONTAINER_CREDS:=-r "registry.wherever.com:myid:mypw"
CONTAINER_CREDS:=

# This statement will automatically configure the ARCH environment variable
ARCH:=$(shell ./helper -a)

default: build run

build:
	docker build -t $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION) -f ./Dockerfile.$(ARCH) .

dev: stop
	docker run -it -v `pwd`:/outside \
	  --privileged \
	  -e ARCH=$(ARCH) \
	  -e NEOPIXEL_COLOR=$(or ${NEOPIXEL_COLOR},'#0000ff') \
	  -e SECONDS_ON=$(or ${SECONDS_ON},'3.5') \
	  -e SECONDS_OFF=$(or ${SECONDS_OFF},'0.25') \
	  --name ${SERVICE_NAME} \
	  $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION) /bin/bash

run: stop
	docker run -d \
	  --privileged \
	  --restart unless-stopped \
	  -e ARCH=$(ARCH) \
	  -e NEOPIXEL_COLOR=$(or ${NEOPIXEL_COLOR},'#0000ff') \
	  -e SECONDS_ON=$(or ${SECONDS_ON},'3.5') \
	  -e SECONDS_OFF=$(or ${SECONDS_OFF},'0.25') \
	  --name ${SERVICE_NAME} \
	  $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION)

test:
	@echo "Look at the pretty color!"

push:
	docker push $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION) 

publish-service:
	@ARCH=$(ARCH) \
	NEOPIXEL_COLOR=$(or ${NEOPIXEL_COLOR},'#0000ff') \
        SERVICE_NAME="$(SERVICE_NAME)" \
        SERVICE_VERSION="$(SERVICE_VERSION)"\
        SERVICE_CONTAINER="$(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION)" \
        hzn exchange service publish -O $(CONTAINER_CREDS) -f service.json --pull-image

publish-pattern:
	@ARCH=$(ARCH) \
        SERVICE_NAME="$(SERVICE_NAME)" \
        SERVICE_VERSION="$(SERVICE_VERSION)"\
        PATTERN_NAME="$(PATTERN_NAME)" \
	hzn exchange pattern publish -f pattern.json

stop:
	@docker kill --signal=SIGTERM ${SERVICE_NAME} >/dev/null 2>&1 || :
	@docker rm -f ${SERVICE_NAME} >/dev/null 2>&1 || :

clean:
	@docker rmi -f $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION) >/dev/null 2>&1 || :

agent-run:
	hzn register --policy privileged.json --pattern "${HZN_ORG_ID}/$(PATTERN_NAME)"

agent-stop:
	hzn unregister -f

.PHONY: default build dev run push stop clean publish-service publish-pattern agent-run agent-stop

