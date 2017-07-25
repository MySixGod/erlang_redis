{application,pool,
             [{description,"a simple spawn pool"},
              {vsn,"1"},
              {registered,[]},
              {applications,[kernel,stdlib]},
              {mod,{pool,[]}},
              {env,[{pools,[{pool1,[{size,10},{max_overflow,20}],[]}]}]},
              {modules,[pool,pool_sup,pool_worker,progress_pool,sup,t,test]}]}.
