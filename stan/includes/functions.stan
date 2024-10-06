functions{
	int square_int(int n){
		return( n * n ) ;
	}

	int lwr_tri_idx_count(int n){
		return( choose(n,2) ) ;
	}

	array[] int lwr_tri_idx(int n) {
		array[lwr_tri_idx_count(n)] int idx ;
		int k = 1 ;
		for (col in 1:(n - 1)) {
			for (row in (col + 1):n) {
				idx[k] = (col - 1) * n + row ;
				k += 1 ;
			}
		}
		return idx ;
	}

	array[,] int get_idx_mat(int n) {
		array[n, n] int idx_mat = rep_array(0, n, n);
		int k = 1;
		for (col in 1:(n - 1)) {
			for (row in (col + 1):n) {
				idx_mat[row, col] = k;
				idx_mat[col, row] = k;  // Since the matrix is symmetric
				k += 1;
			}
		}
		return idx_mat;
	}

	int size_idx_Zv_1(int n_A, int n_B){
			int idx_Zv_1_count = 0 ;
			for (i1 in 1:n_A) {
					for (i2 in 1:n_B) {
							int i = (i1 - 1) * n_B + i2 ;
							for (j1 in 1:n_A) {
									for (j2 in 1:n_B) {
											int j = (j1 - 1) * n_B + j2 ;
											int p = (i - 1) * n_A * n_B + j ;
											if (i1 == j1 && i2 == j2) {
													idx_Zv_1_count += 1 ;
											}
									}
							}
					}
			}
			return(idx_Zv_1_count) ;
	}

	array[] int get_idx_Zv_1(int n_A, int n_B){
			array[size_idx_Zv_1(n_A,n_B)] int idx_Zv_1 ;
			int i_idx_Zv_1 = 1 ;
			for (i1 in 1:n_A) {
					for (i2 in 1:n_B) {
							int i = (i1 - 1) * n_B + i2 ;
							for (j1 in 1:n_A) {
									for (j2 in 1:n_B) {
											int j = (j1 - 1) * n_B + j2 ;
											int p = (i - 1) * n_A * n_B + j ;
											if (i1 == j1 && i2 == j2) {
													idx_Zv_1[i_idx_Zv_1] = p ;
													i_idx_Zv_1 += 1 ;
											}
									}
							}
					}
			}
			return(idx_Zv_1) ;
	}

	int size_idx_Zv_Au(int n_A, int n_B){
		int idx_Zv_Au_count = 0 ;
		for (i1 in 1:n_A) {
			for (i2 in 1:n_B) {
				int i = (i1 - 1) * n_B + i2 ;
				for (j1 in 1:n_A) {
					for (j2 in 1:n_B) {
						int j = (j1 - 1) * n_B + j2 ;
						int p = (i - 1) * n_A * n_B + j ;
						if (i1 != j1 && i2 == j2) {
							idx_Zv_Au_count += 1 ;
						}
					}
				}
			}
		}
		return(idx_Zv_Au_count) ;
	}
	array[,] int get_idx_Zv_Au(int n_A, int n_B, array[,] int idx_mat_A) {
		int size = size_idx_Zv_Au(n_A, n_B);
		array[2, size] int idx_Zv_Au;
		int i_idx_Zv_Au = 1;
		for (i1 in 1:n_A) {
			for (i2 in 1:n_B) {
				int i = (i1 - 1) * n_B + i2;
				for (j1 in 1:n_A) {
					for (j2 in 1:n_B) {
						int j = (j1 - 1) * n_B + j2;
						int p = (i - 1) * n_A * n_B + j;
						if (i1 != j1 && i2 == j2) {
							int idx_Au = idx_mat_A[i1, j1];
							idx_Zv_Au[1, i_idx_Zv_Au] = p;
							idx_Zv_Au[2, i_idx_Zv_Au] = idx_Au;
							i_idx_Zv_Au += 1;
						}
					}
				}
			}
		}
		return idx_Zv_Au;
	}

	int size_idx_Zv_Bu(int n_A, int n_B){
		int idx_Zv_Bu_count = 0 ;
		for (i1 in 1:n_A) {
			for (i2 in 1:n_B) {
				int i = (i1 - 1) * n_B + i2 ;
				for (j1 in 1:n_A) {
					for (j2 in 1:n_B) {
						int j = (j1 - 1) * n_B + j2 ;
						int p = (i - 1) * n_A * n_B + j ;
						if (i1 == j1 && i2 != j2) {
							idx_Zv_Bu_count += 1 ;
						}
					}
				}
			}
		}
		return(idx_Zv_Bu_count) ;
	}
	array[,] int get_idx_Zv_Bu(int n_A, int n_B, array[,] int idx_mat_B){
		array[2,size_idx_Zv_Bu(n_A,n_B)] int idx_Zv_Bu ;
		int i_idx_Zv_Bu = 1 ;
		for (i1 in 1:n_A) {
			for (i2 in 1:n_B) {
				int i = (i1 - 1) * n_B + i2 ;
				for (j1 in 1:n_A) {
					for (j2 in 1:n_B) {
						int j = (j1 - 1) * n_B + j2 ;
						int p = (i - 1) * n_A * n_B + j ;
						if (i1 == j1 && i2 != j2) {
							int idx_Bu = idx_mat_B[i2, j2] ;
							idx_Zv_Bu[1,i_idx_Zv_Bu] = p ;
							idx_Zv_Bu[2,i_idx_Zv_Bu] = idx_Bu ;
							i_idx_Zv_Bu += 1 ;
						}
					}
				}
			}
		}
		return(idx_Zv_Bu) ;
	}

	int size_idx_Zv_Xv(int n_A, int n_B){
		int idx_Zv_Xv_count = 0 ;
		for (i1 in 1:n_A) {
			for (i2 in 1:n_B) {
				int i = (i1 - 1) * n_B + i2 ;
				for (j1 in 1:n_A) {
					for (j2 in 1:n_B) {
						int j = (j1 - 1) * n_B + j2 ;
						int p = (i - 1) * n_A * n_B + j ;
						if (i1 != j1 && i2 != j2) {
							idx_Zv_Xv_count += 1 ;
						}
					}
				}
			}
		}
		return(idx_Zv_Xv_count) ;
	}
	array[,] int get_idx_Zv_Xv(int n_A, int n_B, array[,] int idx_mat_A, array[,] int idx_mat_B){
		int n_Au = choose(n_A,2) ;
		array[2,size_idx_Zv_Xv(n_A,n_B)] int idx_Zv_Xv ;
		int i_idx_Zv_Xv = 1 ;
		for (i1 in 1:n_A) {
			for (i2 in 1:n_B) {
				int i = (i1 - 1) * n_B + i2 ;
				for (j1 in 1:n_A) {
					for (j2 in 1:n_B) {
						int j = (j1 - 1) * n_B + j2 ;
						int p = (i - 1) * n_A * n_B + j ;
						if (i1 != j1 && i2 != j2) {
							int idx_Au = idx_mat_A[i1, j1] ;
							int idx_Bu = idx_mat_B[i2, j2] ;
							int idx_Xv = (idx_Bu - 1) * n_Au + idx_Au ;
							idx_Zv_Xv[1,i_idx_Zv_Xv] = p ;
							idx_Zv_Xv[2,i_idx_Zv_Xv] = idx_Xv ;
							i_idx_Zv_Xv += 1 ;
						}
					}
				}
			}
		}
		return(idx_Zv_Xv) ;
	}


	matrix kronecker_product_corr1(
		matrix A
		, matrix B
	){
		int n_A = rows(A) ;
		int n_B = rows(B) ;
		// Precompute indices
		array[lwr_tri_idx_count(n_A)] int idx_lwr_tri_A = lwr_tri_idx(n_A) ;
		array[lwr_tri_idx_count(n_B)] int idx_lwr_tri_B = lwr_tri_idx(n_B) ;
		int n_Au = choose(n_A, 2);
		int n_Bu = choose(n_B, 2);
		int n_Z = n_A * n_B ;
		int n_Z_square = n_Z *n_Z ;
		int n_Au_Bu = n_Au * n_Bu ;
		array[n_A, n_A] int idx_mat_A = get_idx_mat(n_A);
		array[n_B, n_B] int idx_mat_B = get_idx_mat(n_B);
		array[size_idx_Zv_1(n_A,n_B)] int idx_Zv_1 = get_idx_Zv_1(n_A, n_B) ;
		array[2,size_idx_Zv_Au(n_A,n_B)] int idx_Zv_Au = get_idx_Zv_Au(n_A, n_B, idx_mat_A) ;
		array[2,size_idx_Zv_Bu(n_A,n_B)] int idx_Zv_Bu = get_idx_Zv_Bu(n_A, n_B, idx_mat_B) ;
		array[2,size_idx_Zv_Xv(n_A,n_B)] int idx_Zv_Xv = get_idx_Zv_Xv(n_A, n_B, idx_mat_A, idx_mat_B) ;
		vector[size(idx_Zv_1)] Zv_ones = rep_vector(1.0, size(idx_Zv_1)) ;
		vector[n_Au] Au = to_vector(A)[idx_lwr_tri_A] ;
		vector[n_Bu] Bu = to_vector(B)[idx_lwr_tri_B] ;
		vector[n_Au_Bu] Xv = to_vector(Au*transpose(Bu)) ; // might be faster to expand each by indices to yield all pairwise products
		vector[n_Z_square] Zv;
		Zv[idx_Zv_1] = Zv_ones ;
		Zv[idx_Zv_Au[1]] = Au[idx_Zv_Au[2]] ;
		Zv[idx_Zv_Bu[1]] = Bu[idx_Zv_Bu[2]] ;
		Zv[idx_Zv_Xv[1]] = Xv[idx_Zv_Xv[2]] ;
		return(to_matrix(Zv, n_Z, n_Z)) ;
	}

	matrix kronecker_product_corr2(
		matrix A
		, matrix B
		, int n_A
		, int n_B
		, int n_Au
		, int n_Bu
		, int n_Au_Bu
		, array[] int idx_lwr_tri_A
		, array[] int idx_lwr_tri_B
		, vector Zv_ones
		, array[] int idx_Zv_1
		, array[,] int idx_Zv_Au
		, array[,] int idx_Zv_Bu
		, array[,] int idx_Zv_Xv
		, int n_Z
		, int n_Z_square
	){
		vector[n_Au] Au = to_vector(A)[idx_lwr_tri_A] ;
		vector[n_Bu] Bu = to_vector(B)[idx_lwr_tri_B] ;
		vector[n_Au_Bu] Xv = to_vector(Au*transpose(Bu)) ; // might be faster to expand each by indices to yield all pairwise products
		vector[n_Z_square] Zv;
		Zv[idx_Zv_1] = Zv_ones ;
		Zv[idx_Zv_Au[1]] = Au[idx_Zv_Au[2]] ;
		Zv[idx_Zv_Bu[1]] = Bu[idx_Zv_Bu[2]] ;
		Zv[idx_Zv_Xv[1]] = Xv[idx_Zv_Xv[2]] ;
		return(to_matrix(Zv, n_Z, n_Z)) ;
	}


}
