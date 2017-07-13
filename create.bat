erl -pa  ./ebin  ./deps/mysql/ebin  ./apps/example/ebin
pause
systools:make_script("erlang_redis",[local]).