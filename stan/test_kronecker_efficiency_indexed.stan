#include functions.stan
#include base.stan
model{
	#include kronecker_indexed.stan
	to_vector(Z1) ~ std_normal() ;
}
