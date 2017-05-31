/**************************************************************************
 *  sdc2_MAT.c
 *
 *  Author: Nick Zwart
 *  Date: 2011 mar 22
 *  Rev: 2011 apr 13
 *
 *  Summary: A MATLAB mex wrapper that implements sample density estimation code.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  This code 
 *  is for research and academic purposes and is not intended for 
 *  clinical use.
 *
 **************************************************************************/

/************************************************************************** EXTERNAL LIBS */
#include "mex.h"
#include "xdarray.h"
#include "sdc2_grid.c" 
#include <assert.h>
#include <string.h>

/************************************************************************** MEX Routine 
 * DCF = sdc2_MAT( coords, numIter, effMtx [, verbose, osf, pweights] ) 
 * 
 * REQUIRED:
 *  coords: N-D double-precision matrix >=2D, fastest varying dimension is length 3
 *              trajectory coordinate points scaled between -0.5 to 0.5
 *  numIter: (integer) number of iterations, range >=1
 *  effMtx: (integer) the length of one side of the grid matrix, range >=1
 *
 * OPTIONAL:
 *  verbose: (integer) 1:verbose 0:quiet, default: 1, range >=0
 *  osf: (real) R, the grid oversample factor, default: 2.1, range >=1
 *  pweights: N-D double-precision matrix >= 1D, same size as len( coords )/3
 *              pre-conditioned weights, default: NULL
 *
 * NOTE:  To specify 'osf', you must first provide 'verbose', and to specify
 *        pre-weights, you must first provide 'verbose' and 'osf'.
 */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
	unsigned long i;

	/* help text in the event of an input error */
	const char help_txt[] = "USAGE: (see sdc3_MAT.c) \n\
	* DCF = sdc3_MAT( coords, numIter, effMtx [, verbose, osf, pweights] )  \n\
	*  \n\
	* REQUIRED: \n\
	*  coords: N-D double-precision matrix >=2D, fastest varying dimension is length 2 \n\
	*              trajectory coordinate points scaled between -0.5 to 0.5 \n\
	*  numIter: (integer) number of iterations, range >=1 \n\
	*  effMtx: (integer) the length of one side of the grid matrix, range >=1 \n\
	* \n\
	* OPTIONAL: \n\
	*  verbose: (integer) 1:verbose 0:quiet, default: 1, range >=0 \n\
	*  osf: (real) R, the grid oversample factor, default: 2.1, range >=1 \n\
	*  pweights: N-D double-precision matrix >= 1D, same size as len( coords )/2 \n\
	*              pre-conditioned weights, default: NULL \n\
	* \n\
	* NOTE:  To specify 'osf', you must first provide 'verbose', and to specify \n\
	*        pre-weights, you must first provide 'verbose' and 'osf'.\n\n ";


	/* Check for proper number of arguments */
	/* input: 
	*    REQUIRED: coords, numIter, effMtx 
	*    OPTIONAL: verbose, osf, pre-weights 
	*
	*  TODO:
	*       Better input parameter checking.
	*/
	if (nrhs < 3 && nrhs > 6) 
	{
		mexPrintf("%s",help_txt);
		mexErrMsgTxt("3 required inputs are: coords, numIter, effMtx.");
	}

	/* ouput: weights_out */
	if (nlhs != 1) 
	{
		mexPrintf("%s",help_txt);
		mexErrMsgTxt("Only 1 output arg is returned from sdc3_MAT().");
	}

	/* Forward declaration */
	int nd, *dims;
	long ne, ii;
	const double *dat;

	/** check and retrieve input */
	/* PARAMS */
	int effMtx  = (int) *mxGetPr(prhs[2]);
	int numIter = (int) *mxGetPr(prhs[1]);

	int verbose = 1;
	if(nrhs >= 4) verbose = (int) *mxGetPr(prhs[3]);

	float osf = 2.1;
	if(nrhs >= 5) osf = (float) *mxGetPr(prhs[4]);

	/* COORDS */
	if(verbose) mexPrintf("Copying coordinate array.\n");
	/* check array existence and type */
	assert(prhs[0] != NULL);
	assert(mxIsDouble(prhs[0]));
	/* check for valid array size */
	nd = mxGetNumberOfDimensions(prhs[0]);
	assert(nd > 0); 
	/* check coordinates are in correct shape [2, M, N, ...]*/
	dims = mxGetDimensions(prhs[0]);
	assert(2 == dims[0]);
	/* create xdarray holding the coordinates */ 
	ne = mxGetNumberOfElements(prhs[0]);
	dat = mxGetPr(prhs[0]);
	xdarray_t *coords = new_xdarray();
	assert(coords != NULL); /* malloc error check */
	coords->init(coords, ne, (void*)dat, sizeof(double), nd, dims);

	/* PRE-WEIGHTS */
	xdarray_t *pweights = NULL;
	if (prhs[5] != NULL && nrhs == 6)
	{
		if(verbose) mexPrintf("W_0 = User input pre-weights\n");
		/* check array type */
		assert(mxIsDouble(prhs[5]));
		/* check for valid array size */
		nd = mxGetNumberOfDimensions(prhs[5]);
		assert(nd > 0);
		/* create xdarray holding pre-weights*/
		ne = mxGetNumberOfElements(prhs[5]);
		dat = mxGetPr(prhs[5]);
		pweights = new_xdarray();
		assert(pweights != NULL); /* make sure new mem is allocated */
		pweights->init(pweights, ne, (void*)dat, sizeof(double), 1, NULL);
	}

	/* run sample density estimation */
	if(verbose) mexPrintf("Computing DCF.\n");
	xdarray_t *dcf = sdc2grid_main(coords, pweights, numIter, effMtx, osf);

	/* Create an mxArray for the return argument */ 
	if(verbose) mexPrintf("Copying output to mxArray.\n");
	plhs[0] = mxCreateDoubleMatrix(dcf->size(dcf), 1, mxREAL);
	assert(plhs[0] != NULL); /* check that mem was allocated */
	memcpy( mxGetPr(plhs[0]), dcf->data_ro(dcf), dcf->memsize(dcf));

	/* free temp data */ 
	free_xdarray(coords); 
	free_xdarray(pweights);
	free_xdarray(dcf);
}


