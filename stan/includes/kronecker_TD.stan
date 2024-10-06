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
