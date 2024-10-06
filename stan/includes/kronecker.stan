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
	matrix[n_Z,n_Z] Z1 ;
	profile("Z1"){
		Z1 = kronecker_product_corr1(A,B) ;
	}
	matrix[n_Z,n_Z] Z2 ;
	profile("Z2"){
		Z2 = kronecker_product_corr2(
			// matrix A
			A
			// , matrix B
			, B
			// , int n_A
			, n_A
			// , int n_B
			, n_B
			// , int n_Au
			, n_Au
			// , int n_Bu
			, n_Bu
			// , int n_Au_Bu
			, n_Au_Bu
			// , array[] int idx_lwr_tri_A
			, idx_lwr_tri_A
			// , array[] int idx_lwr_tri_B
			, idx_lwr_tri_B
			// , Zv_ones
			, Zv_ones
			// , array[] int idx_Zv_1 ;
			, idx_Zv_1
			// , array[,] int idx_Zv_Au ;
			, idx_Zv_Au
			// , array[,] int idx_Zv_Bu ;
			, idx_Zv_Bu
			// , array[,] int idx_Zv_Xv ;
			, idx_Zv_Xv
			// , int n_Z ;
			, n_Z
			// , int n_Z_square ;
			, n_Z_square
		) ;
	}
