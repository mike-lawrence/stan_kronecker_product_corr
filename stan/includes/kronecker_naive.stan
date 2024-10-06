	// compute the kronecker product the naive/inefficient way:
	matrix[n_Z,n_Z] Z0 ;
	profile("Z0"){
		for (i in 1:n_A) {
			for (j in 1:n_A) {
				for (p in 1:n_B) {
					for (q in 1:n_B) {
						int row = (i - 1) * n_B + p;
						int col = (j - 1) * n_B + q;
						Z0[row, col] = A[i, j] * B[p, q];
					}
				}
			}
		}
	}
