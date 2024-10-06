data{
	int n_A ;
	int n_B ;
}
transformed data{
	// Precompute quantities for kronecker_product_corr2
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
}
parameters{
	corr_matrix[n_A] A ;
	corr_matrix[n_B] B ;
}
