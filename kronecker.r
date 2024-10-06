library(tidyverse)
# also need `fs` and `cmdstanr` packages

stan_file = 'stan/test_kronecker_accuracy.stan'
stan_exe_dir = fs::path_ext_remove(stan_file) %>% str_replace('stan','stan_exes')
fs::dir_create(stan_exe_dir)
mod = cmdstanr::cmdstan_model(
	stan_file
	, include_paths = 'stan/includes'
	, dir = stan_exe_dir
	, force_recompile = TRUE
	, stanc_options = list()
	, cpp_options = list()
)

# Checking accuracy ----
fs::dir_create('tmp')
post = mod$sample(
	data = list(
		n_A = 10
		, n_B = 10
	)
	, adapt_engaged = FALSE
	, iter_warmup = 0
	, iter_sampling = 1
	, chains = 1
	, sig_figs = 18
	, show_messages = FALSE
	, show_exceptions = FALSE
	, refresh = 0
	, diagnostics = NULL
	, output_dir = 'tmp'
)

draws = posterior::as_draws_rvars(post$draws())
fs::dir_delete('tmp')

Z0 = mean(draws$Z0)
Z1 = mean(draws$Z1)
Z2 = mean(draws$Z2)
# checking against Stan-computed
max(abs(Z0[lower.tri(Z0)] - Z1[lower.tri(Z1)]))
max(abs(Z0[lower.tri(Z0)] - Z2[lower.tri(Z2)]))
# checking against externally-computed
Z4 = fastmatrix::kronecker.prod(
	draws$A %>% mean()
	, draws$B %>% mean()
)
max(abs(Z4[lower.tri(Z4)] - Z2[lower.tri(Z2)]))

# Checking compute efficiency ----
stan_file = 'stan/test_kronecker_efficiency.stan'
stan_exe_dir_default = fs::path_ext_remove(stan_file) %>% str_replace('stan','stan_exes')
fs::dir_create(stan_exe_dir_default)
mod_default = cmdstanr::cmdstan_model(
	stan_file
	, include_paths = 'stan/includes'
	, dir = stan_exe_dir_default
	# , force_recompile = TRUE
	# fast-compute stanc_options:
	, stanc_options = list()
	# fast-compute cpp_options (but not using BLAS/LAPACK)
	, cpp_options = list()
)

stan_exe_dir_fast = paste0(stan_exe_dir,'_fast')
fs::dir_create(stan_exe_dir_fast)
mod_fast = cmdstanr::cmdstan_model(
	stan_file
	, include_paths = 'stan/includes'
	, dir = stan_exe_dir_fast
	# , force_recompile = TRUE
	# fast-compute stanc_options:
	, stanc_options = list('O1')
	# fast-compute cpp_options (but not using BLAS/LAPACK)
	, cpp_options = list(
		stan_threads=FALSE
		, STAN_CPP_OPTIMS=TRUE
		, STAN_NO_RANGE_CHECKS=TRUE
		, CXXFLAGS_OPTIM = "-O3 -march=native -mtune=native"
	)
)

(
	tibble(
		default = list(mod_default)
		, fast = list(mod_fast)
	)
	%>% pivot_longer(
		everything()
		, names_to = 'mod_opts'
		, values_to = 'mod'
	)
	%>% expand_grid(
		# n_A = 2^(1:10)
		n_A = 2:16
		# , n_B = 2^(1:10)
	)
	%>% mutate(n_B=n_A)
	%>% arrange(n_A,n_B,mod_opts)
	# %>% filter(n_A==32)
	%>% group_split(n_A,n_B,mod_opts)
	# %>% pluck(1) -> x)
	%>% {function(x){
		all_out <<- NULL
		return(x)
	}}()
	%>% map_dfr(
		.f = function(x){
			fs::dir_create('tmp')
			# done = FALSE
			# while(!done){
				post = x$mod[[1]]$sample(
					data = list(
						n_A = x$n_A
						, n_B = x$n_B
					)
					# , chains = 1
					, chains = parallel::detectCores()/2
					, parallel_chains = parallel::detectCores()/2
					, show_messages = FALSE
					, show_exceptions = FALSE
					, refresh = 0
					, diagnostics = NULL
					, adapt_engaged = FALSE
					, iter_warmup = 0
					, iter_sampling = 1e3
					, output_dir = 'tmp'
				)
			# }
			(
				post$profiles()
				%>% bind_rows(.id = 'chain')
				%>% select(chain,name,total_time)
				%>% rename(value=total_time)
				%>% pivot_wider()
				%>% select(chain,Z0,Z1,Z2)
				%>% mutate(
					`Z0/Z1` = Z0/Z1
					, `Z1/Z2` = Z1/Z2
					, `Z0/Z2` = Z0/Z2
					, .before = everything()
				)
				%>% summarise(
					across(
						.cols = -chain
						, ~ mean(.)
					)
				)
				%>% mutate(
					mod_opts = x$mod_opts
					, n_A = x$n_A
					, n_B = x$n_B
					, .before = everything()
				)
			) ->
				out
			all_out <<- bind_rows(all_out,out)
			print(all_out,n=nrow(all_out))
			fs::dir_delete('tmp')
			if(x$n_A>1){
				(
					all_out
					%>% ggplot()
					+ geom_hline(yintercept=1,linetype=3)
					+ geom_line(
						aes(
							x = n_A
							, y = `Z0/Z2`
							, colour = mod_opts
						)
					)
					+ labs(
						colour = 'Compile\nOptions'
						, x = 'Problem size\n( kprod([n,n],[n,n]) )'
						, y = 'Time ratio\n( naive / pre-computed-indices )'
					)
				) ->
					p
				print(p)
			}
			return(out)
		}
	)
) ->
	all_out


# Checking compute efficiency via entirely separate models ----

default_opts = list(
	stanc_options = list()
	, cpp_options = list()
)
fast_opts = list(
	stanc_options = list('O1')
	, cpp_options = list(
		stan_threads=FALSE
		, STAN_CPP_OPTIMS=TRUE
		, STAN_NO_RANGE_CHECKS=TRUE
		, CXXFLAGS_OPTIM = "-O3 -march=native -mtune=native"
	)
)


#compiling all models
(
	expand_grid(
		kron = c('naive','indexed','TD')
		, opt_set = c('default','fast')
	)
	%>% group_split(kron,opt_set)
	# %>% pluck(1) -> x)
	%>% map(
		.f = function(x){
			stan_file = (
				fs::path('stan',paste0('test_kronecker_efficiency','_',x$kron),ext='stan')
			)
			stan_exe_dir = (
				stan_file
				%>% fs::path_ext_remove()
				%>% str_replace('stan','stan_exes')
				%>% paste0('_',x$opt_set)
			)
			fs::dir_create(stan_exe_dir)
			x$mod = list(
				cmdstanr::cmdstan_model(
					stan_file
					, include_paths = 'stan/includes'
					, dir = stan_exe_dir
					, stanc_options = get(paste0(x$opt_set,'_opts'))$stanc_options
					, cpp_options = get(paste0(x$opt_set,'_opts'))$cpp_options
				)
			)
			return(x)
		}
	)
) ->
	mod_list

mod_tbl = bind_rows(mod_list)

(
	mod_tbl
	%>% expand_grid(
		# n_A = 2^(1:10)
		n_A = 17:32
		# , n_B = 2^(1:10)
	)
	%>% mutate(n_B=n_A)
	%>% arrange(n_A,n_B,kron,opt_set)
	%>% group_split(n_A,n_B,kron,opt_set)
	# %>% pluck(1) -> x)
	# %>% {function(x){
	# 	all_out <<- NULL
	# 	return(x)
	# }}()
	%>% map_dfr(
		.f = function(x){
			fs::dir_create('tmp')
			# done = FALSE
			# while(!done){
			post = x$mod[[1]]$sample(
				data = list(
					n_A = x$n_A
					, n_B = x$n_B
				)
				# , chains = 1
				, chains = parallel::detectCores()/2
				, parallel_chains = parallel::detectCores()/2
				, show_messages = FALSE
				, show_exceptions = FALSE
				, refresh = 0
				, diagnostics = NULL
				, adapt_engaged = FALSE
				, iter_warmup = 0
				, iter_sampling = 1e3
				, output_dir = 'tmp'
			)
			# }
			(
				post$profiles()
				%>% bind_rows(.id = 'chain')
				%>% summarise(
					value = mean(total_time)
				)
				%>% bind_cols(
					select(x,-mod)
					, .
				)
			) ->
				out
			all_out <<- bind_rows(all_out,out)
			# print(all_out,n=nrow(all_out))
			fs::dir_delete('tmp')
			if(x$n_A>2){
				(
					all_out
					%>% pivot_wider(names_from=kron)
					%>% mutate(
						value = naive / TD
					)
					%>% ggplot()
					+ geom_hline(yintercept=1,linetype=3)
					+ geom_line(
						aes(
							x = n_A
							, y = value
							, colour = opt_set
						)
					)
					+ labs(
						colour = 'Compile\nOptions'
						, x = 'Problem size\n( kprod([n,n],[n,n]) )'
						, y = 'Time ratio\n( naive / pre-computed-indices )'
					)
				) ->
					p
				print(p)
			}
			return(out)
		}
	)
) ->
	all_out
