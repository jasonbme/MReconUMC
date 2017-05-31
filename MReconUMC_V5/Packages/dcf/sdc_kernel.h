/*
 * =====================================================================================
 *
 *       Filename:  sdc_kernel.h
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  28/05/12 20:24:04
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Ghislain Vaillant <ghislain.vaillant@kcl.ac.uk> 
 *   Organization:  King's College London
 *
 * =====================================================================================
 */

#ifndef __SDCKERNEL__
#define __SDCKERNEL__

#include "xdarray.h"

/* CONSTANTS */
/* kernel table lookup size */
#define DEFAULT_KERNEL_TABLE_SIZE 10000
/* default polynomial order*/
#define DEFAULT_POLY_ORDER 5

/* kernel paramaters */
typedef struct _sdc_kernel{
	double rfp;
	long fit_len;
	long fov;
	long spectral_len;
	int poly_order;
	double *poly_coefs;
} sdc_kernel;

static const double SDC2POLY[DEFAULT_POLY_ORDER+1] = {
	-3.86978032e-13,
   	 +2.75948682e-10,
	-1.15028550e-08,
	-2.14617062e-05,
	-1.11761551e-04,
	+9.97513272e-01
};
	
static const double SDC3POLY[DEFAULT_POLY_ORDER+1] = {
	-1.1469041640943728E-13, 
	+8.5313956268885989E-11, 
	+1.3282009203652969E-08, 
	-1.7986635886194154E-05, 
	+3.4511129626832091E-05, 
	+0.99992359966186584 
};

static const sdc_kernel SDC2_KERNEL = {0.775, 310, 64, 25600, DEFAULT_POLY_ORDER, SDC2POLY};
static const sdc_kernel SDC3_KERNEL = {0.96960938, 394, 63, 25600, DEFAULT_POLY_ORDER, SDC3POLY};

xdarray_t* eval_kernel(sdc_kernel, long);

#endif
