#include functions.stan
#include base.stan
transformed parameters{
	#include kronecker.stan
}
model{
	#include target.stan
}
