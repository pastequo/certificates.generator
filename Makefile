DEVICE_DIR=$(PWD)/device
SERVER_DIR=$(PWD)/server

.PHONY: server device server.clear device.clear

server: server.root server.intermediate server.leaf
device: device.root device.intermediate device.leaf

server.clear: server.root.clear server.intermediate.clear server.leaf.clear
device.clear: device.root.clear device.intermediate.clear device.leaf.clear


.PHONY: server.root server.intermediate server.leaf server.root.clear server.intermediate.clear server.leaf.clear

server.root.clear:
	cd $(SERVER_DIR)/root/ && rm -fr cert.pem certs/* index* privatekey.pem serial*
	echo 01 > $(SERVER_DIR)/root/serial.txt
	touch $(SERVER_DIR)/root/index.txt
	touch $(SERVER_DIR)/root/index.txt.attr

server.intermediate.clear:
	cd $(SERVER_DIR)/intermediate/ && rm -fr cert.pem cert.csr certs/* index* privatekey.pem serial*
	echo 01 > $(SERVER_DIR)/intermediate/serial.txt
	touch $(SERVER_DIR)/intermediate/index.txt
	touch $(SERVER_DIR)/intermediate/index.txt.attr

server.leaf.clear:
	cd $(SERVER_DIR)/leaf/ && rm -fr cert.pem cert.csr cert.fullchain.pem cert.with_private_key.pem privatekey.pem

server.root:
	openssl req -x509 -config $(SERVER_DIR)/root/cert.conf -newkey rsa:4096 -sha256 -nodes -out $(SERVER_DIR)/root/cert.pem -outform PEM

server.intermediate:
	openssl req -config $(SERVER_DIR)/intermediate/cert.conf -newkey rsa:4096 -sha256 -nodes -out $(SERVER_DIR)/intermediate/cert.csr -outform PEM
	openssl ca -config $(SERVER_DIR)/root/cert.conf -policy signing_policy -extensions v3_intermediate_ca -out $(SERVER_DIR)/intermediate/cert.pem -infiles $(SERVER_DIR)/intermediate/cert.csr

server.leaf:
	openssl req -config $(SERVER_DIR)/leaf/cert.conf -newkey rsa:4096 -sha256 -nodes -out $(SERVER_DIR)/leaf/cert.csr -outform PEM
	openssl ca -config $(SERVER_DIR)/intermediate/cert.conf -policy signing_policy -extensions signing_req -out $(SERVER_DIR)/leaf/cert.pem -infiles $(SERVER_DIR)/leaf/cert.csr
	cat $(SERVER_DIR)/leaf/cert.pem $(SERVER_DIR)/intermediate/cert.pem $(SERVER_DIR)/root/cert.pem > $(SERVER_DIR)/leaf/cert.fullchain.pem
	cat $(SERVER_DIR)/leaf/cert.fullchain.pem $(SERVER_DIR)/leaf/privatekey.pem > $(SERVER_DIR)/leaf/cert.with_private_key.pem


.PHONY: device.root device.intermediate device.leaf device.root.clear device.intermediate.clear device.leaf.clear

device.root.clear:
	cd $(DEVICE_DIR)/root/ && rm -fr cert.pem certs/* index* privatekey.pem serial*
	echo 01 > $(DEVICE_DIR)/root/serial.txt
	touch $(DEVICE_DIR)/root/index.txt
	touch $(DEVICE_DIR)/root/index.txt.attr

device.intermediate.clear:
	cd $(DEVICE_DIR)/intermediate/ && rm -fr cert.pem cert.csr certs/* index* privatekey.pem serial*
	echo 01 > $(DEVICE_DIR)/intermediate/serial.txt
	touch $(DEVICE_DIR)/intermediate/index.txt
	touch $(DEVICE_DIR)/intermediate/index.txt.attr

device.leaf.clear:
	cd $(DEVICE_DIR)/leaf/ && rm -fr cert.pem cert.csr cert.fullchain.pem privatekey.pem

device.root:
	openssl req -x509 -config $(DEVICE_DIR)/root/cert.conf -newkey rsa:4096 -sha256 -nodes -out $(DEVICE_DIR)/root/cert.pem -outform PEM

device.intermediate:
	openssl req -config $(DEVICE_DIR)/intermediate/cert.conf -newkey rsa:4096 -sha256 -nodes -out $(DEVICE_DIR)/intermediate/cert.csr -outform PEM
	openssl ca -config $(DEVICE_DIR)/root/cert.conf -policy signing_policy -extensions v3_intermediate_ca -out $(DEVICE_DIR)/intermediate/cert.pem -infiles $(DEVICE_DIR)/intermediate/cert.csr

device.leaf:
	openssl req -config $(DEVICE_DIR)/leaf/cert.conf -newkey rsa:4096 -sha256 -nodes -out $(DEVICE_DIR)/leaf/cert.csr -outform PEM
	openssl ca -config $(DEVICE_DIR)/intermediate/cert.conf -policy signing_policy -extensions signing_req -out $(DEVICE_DIR)/leaf/cert.pem -infiles $(DEVICE_DIR)/leaf/cert.csr
	cat $(DEVICE_DIR)/leaf/cert.pem $(DEVICE_DIR)/intermediate/cert.pem $(DEVICE_DIR)/root/cert.pem > $(DEVICE_DIR)/leaf/cert.fullchain.pem

