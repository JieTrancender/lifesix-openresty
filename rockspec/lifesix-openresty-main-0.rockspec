package = "lifesix-openresty"
version = "main-0"
supported_platforms = {"linux", "macosx"}

source = {
    url = "git@github.com:JieTrancender/lifesix-openresty.git",
    branch = "main",
}

description = {
    summary = "",
    homepage = "https://github.com/JieTrancender/lifesix-openresty",
    license = "Apache License 2.0",
}

dependencies = {
    "resty-redis-cluster = 1.02-4",
}

build = {
    type = "make",
    build_variables = {
        CFLAGS="$(CFLAGS)",
        LIBFLAG="$(LIBFLAG)",
        LUA_LIBDIR="$(LUA_LIBDIR)",
        LUA_BINDIR="$(LUA_BINDIR)",
        LUA_INCDIR="$(LUA_INCDIR)",
        LUA="$(LUA)",
        OPENSSL_INCDIR="$(OPENSSL_INCDIR)",
        OPENSSL_LIBDIR="$(OPENSSL_LIBDIR)",
    },
    install_variables = {
        ENV_INST_PREFIX="$(PREFIX)",
        ENV_INST_BINDIR="$(BINDIR)",
        ENV_INST_LIBDIR="$(LIBDIR)",
        ENV_INST_LUADIR="$(LUADIR)",
        ENV_INST_CONFDIR="$(CONFDIR)",
    },
}
