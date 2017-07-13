{application, example, [
  {description, "An example application"},
  {vsn, "1.5.1"},
  {applications, [kernel, stdlib, sasl]},
  {modules, [example, example_worker,poolboy,poolboy_sup,poolboy_worker]},
  {registered, [example]},
  {mod, {example, []}},
  {env, [
    {pools, [
      {pool1, [
        {size, 10},
        {max_overflow, 20}
      ], [
        {hostname, "127.0.0.1"},
        {database, "hello"},
        {username, "root"},
        {password, "cwtborn123"}
      ]}
    ]}
  ]}
]}.
