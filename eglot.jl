import Pkg
Pkg.activate(@__DIR__)

using LanguageServer, Sockets, SymbolServer

server = LanguageServer.LanguageServerInstance(stdin, stdout, false,
                                               ARGS[1], ARGS[2], Dict())

# server = LanguageServerInstance(stdin, stdout, true, "~/.julia/environments/v1.2", "", Dict())
# run(server)

server.runlinter = true
run(server)
