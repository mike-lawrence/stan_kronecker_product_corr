source('~/_.Rprofile')

# stan_file = 'stan/test_lwr_tri_idx.stan'
stan_file = 'stan/test_kronecker_accuracy.stan'
stan_exe_dir = fs::path_ext_remove(stan_file) %>% str_replace('stan','stan_exes')
fs::dir_create(stan_exe_dir)
mod = cmdstanr::cmdstan_model(
	stan_file
	, dir = stan_exe_dir
	# , force_recompile = TRUE
	, stanc_options = list()
	, cpp_options = list()
)

# Checking accuracy ----
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
)

draws = posterior::as_draws_rvars(post$draws())
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
		default = list(mod)
		, fast_opts = list(mod_fast)
	)
	%>% pivot_longer(
		everything()
		, names_to = 'mod_name'
		, values_to = 'mod'
	)

	%>% expand_grid(
		n_A = 2^(1:10)
		# , n_B = 2:10
	)
	%>% mutate(n_B=n_A)
	%>% arrange(n_A,n_B,mod_name)
	# %>% filter(n_A==32)
	%>% group_split(n_A,n_B,mod_name)
	# %>% pluck(1) -> x)
	%>% {function(x){
		all_out <<- NULL
		return(x)
	}}()
	%>% map_dfr(
		.f = function(x){
			fs::dir_create('tmp')
			tmpdir = tempdir()
			# done = FALSE
			# while(!done){
				post = x$mod[[1]]$sample(
					data = list(
						n_A = x$n_A
						, n_B = x$n_B
					)
					, chains = parallel::detectCores()/2
					, parallel_chains = parallel::detectCores()/2
					, show_messages = FALSE
					, show_exceptions = FALSE
					, refresh = 0
					, diagnostics = NULL
					, adapt_engaged = FALSE
					, iter_warmup = 0
					, iter_sampling = 1e2
					, output_dir = 'tmp'
				)
			# }
			(
				post$profiles()
				%>% bind_rows(.id = 'chain')
				%>% select(chain,name,total_time)
				%>% rename(value=total_time)
				%>% pivot_wider()
				%>% mutate(
					ratio_Z0_div_Z1 = Z0/Z1
					, ratio_Z1_div_Z2 = Z1/Z2
					, ratio_Z0_div_Z2 = Z0/Z2
					, .before = everything()
				)
				%>% summarise(
					across(
						.cols = -chain
						, ~ mean(.)
					)
				)
				%>% mutate(
					mod_name = x$mod_name
					, n_A = x$n_A
					, n_B = x$n_B
					, .before = everything()
				)
			) ->
				out
			all_out <<- bind_rows(all_out,out)
			print(all_out)
			fs::dir_delete('tmp')
			return(out)
		}
	)
) ->
	all_out
