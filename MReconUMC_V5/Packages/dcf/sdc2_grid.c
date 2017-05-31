/*
 * =====================================================================================
 *
 *       Filename:  sdc3_grid.c
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  07/06/12 17:19:42
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Ghislain Vaillant <ghislain.vaillant@kcl.ac.uk>
 *   Organization:  King's College London
 *
 * =====================================================================================
 */

#include "sdc_kernel.h"
#include "xdarray.h"
#include <assert.h>
#include <math.h>

void set_minmax (double x, long *min, long *max, long maximum, double radius)	
{
	*min = (long) ceil (x - radius);
	*max = (long) floor (x + radius);
	if (*min < 0) *min = 0;
	if (*max >= maximum) *max = maximum-1;
}

	void 
grid2(  xdarray_t *grid_out, 
        const xdarray_t *coords_in, 
        const xdarray_t *weight_in, 
        const xdarray_t *kernel_in, 
        double radiusFOVproduct, 
        double windowLength   )
{
    	/* sanity checks */
    	assert( grid_out != NULL );      /* check that grid exists */
    	assert( coords_in != NULL );     /* check that coords exist */
    	assert( weight_in != NULL );     /* check that weights exists */
    	assert( kernel_in != NULL );     /* check that kernel exists */
	assert( radiusFOVproduct > 0.0); /* valid kernel radius in pix */
	assert( windowLength > 0.0);     /* valid coord scale */
	assert( grid_out->dim(grid_out, 0) == grid_out->dim(grid_out, 1) ); 
		/* grid has to be square*/
        assert( weight_in->size(weight_in) == (coords_in->size(coords_in) / 2) );
		/* check consistancy between provided trajectory and weights */

	/* grid size this has already been multiplied by osf */
	/* assuming cubic grid, only first dim has to be read */
	int width = grid_out->dim(grid_out, 0);    
	double width_inv = 1.0 / width;

	/* get center pt for relative position */
	int center = width / 2;

	/* Calculate kernel radius in units of pixels and 1/FOV 
	*    - rfp should also be appropriately scaled by osf */
	double kernelRadius           = radiusFOVproduct / (double)width;
	double kernelRadius_sqr       = kernelRadius * kernelRadius;
	double kernelRadius_invSqr    = 1.0 / kernelRadius_sqr;

	/* scale grid point in pixels to match table size */
	double dist_multiplier = (double)(kernel_in->size(kernel_in) - 1) * kernelRadius_invSqr;

	/* make sure output array is zero before gridding to it */
   	/* FIX: not needed anymore, user should provide an initialized xdarray_t instead 
 	* 
 	* unsigned long ii;
 	* for(ii=0;ii<grid_out->num_elem;ii++) grid_out->data[ii] = 0.;
 	* */ 

	/* Forward declaration */	
	long p, ind, kerind;
	long imin, imax, jmin, jmax, i, j;
	double x, y, ix, jy;
	double dx_sqr, dy_sqr, dist_sqr;
	double dat, ker, *gdat;
	
	/* grid main loop */
	for (p = 0; p < weight_in->size(weight_in); p++)
    	{
		/* Get the current trajectory coordinate to grid. */
        	ind = p * 2;
        	/* x = coords_in->data[ind]   / windowLength;  coords_in should vary between -.5 to +.5, */
        	/* y = coords_in->data[ind+1] / windowLength;  windowLength can be used to correct the scale */
        	/* z = coords_in->data[ind+2] / windowLength; */	
		x = *(double*)coords_in->get(coords_in, ind) / windowLength;		
		y = *(double*)coords_in->get(coords_in, ind+1) / windowLength;		

        	/* Get the current weight. */
        	/*dat = weight_in->data[p];*/
		dat = *(double*)weight_in->get(weight_in, p);

		/* Find the grid boundaries for this point. */
        	ix = x * width + center;
        	set_minmax(ix, &imin, &imax, width, radiusFOVproduct);
        	jy = y * width + center;
        	set_minmax(jy, &jmin, &jmax, width, radiusFOVproduct);

		/* Grid the current non-uniform point onto the neighboring Cartesian points. */
		for (j=jmin; j<=jmax; j++)	
		{
			jy = (j - center) * width_inv;
			dy_sqr = jy - y;
			dy_sqr *= dy_sqr;
			if (dy_sqr < kernelRadius_sqr) /* kernel bounds check */
			{
				for (i=imin; i<=imax; i++)	
				{
					ix = (i - center) * width_inv;
					dx_sqr = ix - x;
					dx_sqr *= dx_sqr;
					dist_sqr = dx_sqr + dy_sqr;
					if (dist_sqr < kernelRadius_sqr) /* kernel bounds check */
					{
						/* calculate corresponding kernel index */
						kerind = (long)(dist_sqr * dist_multiplier + 0.5);
						/* get kernel value, round to the closest table pt */
						ker = *(double*)kernel_in->get(kernel_in, kerind);
						/* grid the current weight based position within the kernel */
						gdat = (double*)grid_out->get2d(grid_out, (int)i, (int)j);
						*gdat += (dat * ker);
					} /* kernel bounds check */
				} /* x 	 */
			} /* kernel bounds check */
		} /* y */
	} /* current data point */
}

	void 
degrid2(xdarray_t *weight_out,    
        const xdarray_t *coords_in, 
	const xdarray_t *grid_in, 
        const xdarray_t *kernel_in, 
        double radiusFOVproduct, 
        double windowLength)
{
    	/* sanity checks */
    	assert( weight_out != NULL );      
    	assert( grid_in != NULL );      
    	assert( coords_in != NULL );     
    	assert( kernel_in != NULL );     
	assert( radiusFOVproduct > 0.0 ); /* valid kernel radius in pix */
	assert( windowLength > 0.0 );     /* valid coord scale */
	assert( grid_in->dim(grid_in, 0) == grid_in->dim(grid_in, 1) ); 
		/* grid has to be square*/
      /*  assert( weight_in->size(weight_out) == (coords_in->size(coords_in) / 2) ); */
		/* check consistancy between provided trajectory and weights */

	/* assuming cubic grid, only first dim has to be read */
	int width = grid_in->dim(grid_in, 0);    
	int width_div2 = width / 2;
	double width_inv = 1.0 / width;
	/* Calculate kernel radius in units of pixels and 1/FOV 
	*    - rfp should also be appropriately scaled by osf */
	double kernelRadius           = radiusFOVproduct / (double)width;
	double kernelRadius_sqr       = kernelRadius * kernelRadius;
	double kernelRadius_invSqr    = 1.0 / kernelRadius_sqr;
	/* scale grid point in pixels to match table size */
	double dist_multiplier = (double)(kernel_in->size(kernel_in) - 1) * kernelRadius_invSqr;

	/* forward declaration */
    	double dy_sqr, dx_sqr;
	double dist_sqr, ker, sum, gdat;
	double x, y, ix, jy;
	long imin, imax, jmin, jmax, i, j;
	long p, ind, kerind;

    	/* start degrid loop */
	for (p = 0; p < weight_out->size(weight_out); p++)
    	{
        	/* reset sum for next point */
		sum = 0.0;

		/* Get the current trajectory coordinate to grid. */
        	ind = p * 2;
		x = *(double*)coords_in->get(coords_in, ind) / windowLength;		
		y = *(double*)coords_in->get(coords_in, ind+1) / windowLength;		
		
        	/* Find the grid boundaries for this point. */
		ix = x * width + width_div2;
		set_minmax(ix, &imin, &imax, width, radiusFOVproduct);
		jy = y * width + width_div2;
		set_minmax(jy, &jmin, &jmax, width, radiusFOVproduct);

		/* Sum all neighboring points that fall under the kernel. */
		for (j=jmin; j<=jmax; j++)	
		{
			jy = (j - width_div2) * width_inv;
			dy_sqr = jy - y;
			dy_sqr *= dy_sqr;
			if (dy_sqr < kernelRadius_sqr) /* kernel bounds check */
			{
				for (i=imin; i<=imax; i++)	
				{
					ix = (i - width_div2) * width_inv;
					dx_sqr = ix - x;
					dx_sqr *= dx_sqr;
					dist_sqr = dx_sqr + dy_sqr;
					if (dist_sqr < kernelRadius_sqr) /* kernel bounds check */
					{
						/* calculate corresponding kernel index */
						kerind = (long)(dist_sqr * dist_multiplier + 0.5);
						/* get kernel value, round to the closest table pt */
						ker = *(double*)kernel_in->get(kernel_in, kerind);
						/* grid the current weight based position within the kernel */
						gdat = *(double*)grid_in->get2d(grid_in, (int)i, (int)j);
						/* update sum for current point */
						sum += (gdat * ker);
					} /* bounds check */
				} /* x */
			} /* bounds check */
		} /* y */

        	/* store sum in the current trajectory point */
		weight_out->set(weight_out, &sum, p);

	} /* next point */
}

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  sdc2grid_main
 *  Description:  
 * =====================================================================================
 */
	xdarray_t*
sdc2grid_main ( const xdarray_t *coords_in, 	/* coordinates to estimate density thereof */
		const xdarray_t *weights_in, 	/* pre-weights */
		int numIter, 			/* number of iterations to perform */
		int effectiveMatrix, 		/* supported matrix size */
		float osf )			/* oversampling factor */
{
    	/* check user input */
	assert (coords_in != NULL);
    	assert (numIter > 0); 		/* the number of iterations should be at least one */
    	assert (effectiveMatrix > 0); 	/* the size of the intermediate grid should be at least one pixel */
    	assert (osf > 0); 		/* the sample factor must be positive */

	/* forawrd declaration */
	long ii, jj, num_weights;
	double *w_ji, *d_ji, *dat;

	/* input params */
	/* double rfp = RADIUS_FOV_PRODUCT;*/ 
	double rfp = SDC2_KERNEL.rfp;  
	/* get grid matrix sizes */
	int grid_mat = (int)(effectiveMatrix * osf);
	/* rfp is defined as 2FOV*kr so osf is relative to 2 */
	float norm_rfp = rfp * osf;
	/* scale the coords to fit on the grid including kernel radius */
	double winLen = ((float)grid_mat + norm_rfp * 2.0) / (float)grid_mat;
    	/* allocate kernel table memory and load */
    	xdarray_t *kernelTable = eval_kernel(SDC2_KERNEL, (long)(DEFAULT_KERNEL_TABLE_SIZE*osf));

	/* 
 	* define intermediate grid used for successive gridding and degridding
 	* operations. 
 	*/
	xdarray_t *grid_tmp = new_xdarray();
	grid_tmp->init2d(grid_tmp, grid_mat, NULL, sizeof(double));
	/* 
 	* define intermediate array holding the current iteration of weights
 	* if pre-weighting is provided then the array is constructed by copy
 	* else the array is constructed and initialized with ones. 
 	*/
	xdarray_t *weights_tmp = NULL;
	if (weights_in != NULL)
		weights_tmp = copy_xdarray(weights_in);
	else
	{
		weights_tmp = new_xdarray();
		/* derive number of samples from trajectory */
		long ne = coords_in->size(coords_in) / 2;
		/* allocate array */		
		weights_tmp->init(weights_tmp, ne, NULL, sizeof(double), 1, NULL);
		/* initialize all weights to 1 */
		dat = (double*)weights_tmp->data_rw(weights_tmp);
		for (ii=0; ii<ne; ii++)
			*(dat++) = 1.0;
		/* TODO: implement an initializer with a specific value */
	}
	num_weights = weights_tmp->size(weights_tmp);
	/* 
 	* define DCF array holding the iteratively computed weights
 	* initialize as a copy of the first iteration of weights
 	*/
	xdarray_t *density_out = copy_xdarray(weights_tmp);

	/* ITERATION LOOP
	*
	*  1) grid: I = ( W * C ) G
	*      
	*  2) degrid: D = I * C
	*
	*  3) invert density to get weights: W = 1/D
	*/

	for(jj=0;jj<numIter;jj++)
	{
		/* 0. clear intermediate grid */
		grid_tmp->clear(grid_tmp);
		/* 1. grid */
		grid2 (grid_tmp, coords_in, density_out, kernelTable, norm_rfp, winLen); 
		/* 2. degrid */
		degrid2 (weights_tmp, coords_in, grid_tmp, kernelTable, norm_rfp, winLen);
		/* 3. compute weights */
		w_ji = (double*)weights_tmp->data_rw(weights_tmp);
		d_ji = (double*)weights_tmp->data_rw(density_out);
		for(ii=0; ii<num_weights; ii++)
		{
		    /* printf("w_ij[%ld] = %.3f, d_ij[%ld] = %.3f\n", ii, *w_ji, ii, *d_ji);*/
		    if (*w_ji == 0) *d_ji = 0;
		    else *d_ji /= (*w_ji);
		    d_ji++; w_ji++;
		}
	}

	/* free temp fields */
	free_xdarray(grid_tmp);
	free_xdarray(weights_tmp);
	free_xdarray(kernelTable);

	return density_out;
}		/* -----  end of function sdc2grid_main  ----- */

