#include functions.stan
#include base.stan
model{
	#include kronecker_TD.stan
	to_vector(Z2) ~ std_normal() ;
}
