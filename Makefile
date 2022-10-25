# Makefile basic env setting
.DEFAULT_GOAL := help
# add pipefail support for default shell
SHELL := /bin/bash -o pipefail


# Project basic setting
VERSION                ?= master
project_name           ?= apache-apisix
project_release_name   ?= $(project_name)-$(VERSION)-src


# Hyperconverged Infrastructure
ENV_OS_NAME            ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
ENV_OS_ARCH            ?= $(shell uname -m | tr '[:upper:]' '[:lower:]')
ENV_GIT                ?= git
ENV_TAR                ?= tar
ENV_INSTALL            ?= install
ENV_RM                 ?= rm -vf
ENV_NGINX              ?= $(ENV_NGINX_EXEC) -p $(CURDIR) -c $(CURDIR)/conf/nginx.conf
ENV_NGINX_EXEC         := $(shell command -v openresty 2>/dev/null || command -v nginx 2>/dev/null)
ENV_OPENSSL_PREFIX     ?= $(addprefix $(ENV_NGINX_PREFIX), openssl)
ENV_LUAROCKS           ?= luarocks
## These variables can be injected by luarocks
ENV_INST_PREFIX        ?= /usr
ENV_INST_LUADIR        ?= $(ENV_INST_PREFIX)/share/lua/5.1
ENV_INST_BINDIR        ?= $(ENV_INST_PREFIX)/bin
ENV_HOMEBREW_PREFIX    ?= /usr/local


# Makefile basic extension function
_color_red    =\E[1;31m
_color_green  =\E[1;32m
_color_yellow =\E[1;33m
_color_blue   =\E[1;34m
_color_wipe   =\E[0m


define func_echo_status
	printf "[%b info %b] %s\n" "$(_color_blue)" "$(_color_wipe)" $(1)
endef


define func_echo_warn_status
	printf "[%b info %b] %s\n" "$(_color_yellow)" "$(_color_wipe)" $(1)
endef


define func_echo_success_status
	printf "[%b info %b] %s\n" "$(_color_green)" "$(_color_wipe)" $(1)
endef


# Makefile target
.PHONY: runtime
runtime:
ifeq ($(ENV_NGINX_EXEC), )
ifeq ("$(wildcard /usr/local/openresty-debug/bin/openresty)", "")
	@$(call func_echo_warn_status, "WARNING: OpenResty not found. You have to install OpenResty and add the binary file to PATH before install Apache APISIX.")
	exit 1
else
	$(eval ENV_NGINX_EXEC := /usr/local/openresty-debug/bin/openresty)
	@$(call func_echo_status, "Use openresty-debug as default runtime")
endif
endif


### deps : Installation dependencies
.PHONY: deps
deps: runtime
	$(eval ENV_LUAROCKS_VER := $(shell $(ENV_LUAROCKS) --version | grep -E -o "luarocks [0-9]+."))
	@if [ '$(ENV_LUAROCKS_VER)' = 'luarocks 3.' ]; then \
		mkdir -p ~/.luarocks; \
		$(ENV_LUAROCKS) config $(ENV_LUAROCKS_FLAG_LOCAL) variables.OPENSSL_LIBDIR $(addprefix $(ENV_OPENSSL_PREFIX), /lib); \
		$(ENV_LUAROCKS) config $(ENV_LUAROCKS_FLAG_LOCAL) variables.OPENSSL_INCDIR $(addprefix $(ENV_OPENSSL_PREFIX), /include); \
		$(ENV_LUAROCKS) install rockspec/lifesix-openresty-main-0.rockspec --tree=deps --only-deps --local $(ENV_LUAROCKS_SERVER_OPT); \
	else \
		$(call func_echo_warn_status, "WARNING: You're not using LuaRocks 3.x; please remove the luarocks and reinstall it via https://raw.githubusercontent.com/apache/apisix/master/utils/linux-install-luarocks.sh"); \
		exit 1; \
	fi


### run : Start the lifesix openresty server
.PHONY: run
run: runtime
	@$(call func_echo_status, "$@ -> [ Start ]")
	@openresty -p ${PWD} -c conf/nginx.conf
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### verify : Verify the configuration of lifesix openresty server
.PHONY: verify
verify: runtime
	@$(call func_echo_status, "$@ -> [ Start ]")
	@openresty -p ${PWD} -c conf/nginx.conf -t
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### stop : Stop the lifesix openresty server, exit immediately
.PHONY: stop
stop: runtime
	@$(call func_echo_status, "$@ -> [ Start ]")
	@openresty -p ${PWD} -c conf/nginx.conf -s stop
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### clean : Remove generated files
.PHONY: clean
clean:
	@$(call func_echo_status, "$@ -> [ Start ]")
	rm -rf logs/
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### reload : Reload the apisix server
.PHONY: reload
reload: runtime
	@$(call func_echo_status, "$@ -> [ Start ]")
	@openresty -p ${PWD} -c conf/nginx.conf -s reload
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### help : Show Makefile rules
### 	If there're awk failures, please make sure
### 	you are using awk or gawk
.PHONY: help
help:
	@$(call func_echo_success_status, "Makefile rules:")
	@echo
	@if [ '$(ENV_OS_NAME)' = 'darwin' ]; then \
		awk '{ if(match($$0, /^#{3}([^:]+):(.*)$$/)){ split($$0, res, ":"); gsub(/^#{3}[ ]*/, "", res[1]); _desc=$$0; gsub(/^#{3}([^:]+):[ \t]*/, "", _desc); printf("    make %-15s : %-10s\n", res[1], _desc) } }' Makefile; \
	else \
		awk '{ if(match($$0, /^\s*#{3}\s*([^:]+)\s*:\s*(.*)$$/, res)){ printf("    make %-15s : %-10s\n", res[1], res[2]) } }' Makefile; \
	fi
	@echo
