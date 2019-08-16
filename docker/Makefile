REGISTORY := registry.ritc.jp/ricos/frontistr

all: image

login:
	docker login $(REGISTORY)

image:
	docker build -t $(REGISTORY)/build .

push: image
	docker push $(REGISTORY)/build
