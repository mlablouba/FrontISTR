REGISTORY := registry.ritc.jp/ricos/frontistr

all: image

login:
	docker login $(REGISTORY)

image: ninja
	docker build -t $(REGISTORY)/build .

push: image
	docker push $(REGISTORY)/build

ninja:
	curl -LO https://github.com/ninja-build/ninja/releases/download/v1.9.0/ninja-linux.zip
	unzip ninja-linux.zip
