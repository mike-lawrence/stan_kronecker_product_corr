#include functions.stan
#include base.stan
model{
	#include kronecker_naive.stan
	to_vector(Z0) ~ std_normal() ;
}
