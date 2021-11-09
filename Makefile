REPOSITORY := quay.io/hakuyume/libtorch

BASE := ubuntu20.04
CUDA := 11.3.1
CUDNN := 8
TORCH := 1.10.0
TORCHVISION := 0.11.1

TAG := $(TORCH)-torchvision$(TORCHVISION)-cuda$(CUDA)-cudnn$(CUDNN)-runtime-$(BASE)

.PHONY: build
build:
	docker build . \
	--build-arg BASE=$(BASE) \
	--build-arg CUDA=$(CUDA) \
	--build-arg CUDNN=$(CUDNN) \
	--build-arg TORCH=$(TORCH) \
	--build-arg TORCHVISION=$(TORCHVISION) \
	--tag $(REPOSITORY):$(TAG)

.PHONY: push
push: build
	docker push $(REPOSITORY):$(TAG)
