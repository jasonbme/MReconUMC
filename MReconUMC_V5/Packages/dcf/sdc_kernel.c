/*
 * =====================================================================================
 *
 *       Filename:  sdc_kernel.c
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  05/06/12 19:21:06
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Ghislain Vaillant <ghislain.vaillant@kcl.ac.uk>
 *   Organization:  King's College London 
 *
 * =====================================================================================
 */
#include "sdc_kernel.h"

#include <assert.h>
#include <math.h>
#include <stdlib.h>

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  polyval
 *  Description:  
 * =====================================================================================
 */
	double
polyval ( double x, int order, const double *coefs )
{
	double out, x_pow_n;
	int n;
	
	/* x^0 */
	x_pow_n = 1.0;
	out = coefs[order];

	/* x^n, n in [1, order]*/
	for (n=1; n<=order; n++)
	{
		x_pow_n *= x;
		out += x_pow_n * coefs[order-n];  
	}

	return out;
}		/* -----  end of function polyval  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  eval_kernel
 *  Description:  
 * =====================================================================================
 */
	xdarray_t*
eval_kernel ( sdc_kernel sdk, long ksize )
{
	assert (ksize > 0);

	long ii = 0;
	double x, sca, kdat;

	xdarray_t *klut = new_xdarray();
	klut->init(klut, ksize, NULL, sizeof(double), 1, NULL);

	/* fix scaling factor to convert an array index to its position in the polynomial 
 	* fit */
	sca = sdk.rfp * sdk.spectral_len / sdk.fov; 

	for (ii=0; ii<ksize; ii++)
	{
		/* scale kernel index to polyfit location */
		x = sqrt((double)ii / (double)(ksize-1)) * sca;

		/* zero-out data outside the polyfit domain */
		kdat = (x >= sdk.fit_len)? 0 : polyval(x, sdk.poly_order, sdk.poly_coefs);
		
		/* clip negative data in case of */
		if (kdat < 0) kdat = 0;
		
		/* fill kernel LUT */
		klut->set(klut, &kdat, ii);	
	}

	return klut;
}		/* -----  end of function eval_kernel  ----- */






