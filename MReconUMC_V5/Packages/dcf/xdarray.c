/*
 * =====================================================================================
 *
 *       Filename:  xdarray.c
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  13/05/12 12:43:52
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Ghislain Vaillant (ghislain.vaillant@kcl.ac.uk) 
 *   Organization:  King's College London
 *
 * =====================================================================================
 */

/* INCLUDES */
#include "xdarray.h"
#include <assert.h>
#include <string.h>

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  xdarray_clear
 *  Description:  
 * =====================================================================================
 */
	void
xdarray_clear ( const void *self )
{
	const xdarray_t *xda = ((xdarray_t*) self);
	memset(xda->data, 0, xda->ne*xda->esize);
}		/* -----  end of function xdarray_clear  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  xdarray_init
 *  Description:  
 * =====================================================================================
 */
	void
xdarray_init ( const void *self, long nelem, void *data, size_t elem_size, int ndims, 
	int *dims )
{
	xdarray_t *xda = ((xdarray_t*) self);
	
	/* sanity checks on inputs */
	assert (nelem >= 1);	/* minimum 1 sample */
	assert (elem_size > 0);	/* 0 size element does not make sense */
	assert (ndims >= 1);	/* number of dimensions should be at least one */

	/* incompatible cases */
	assert (!((ndims > 1) && (dims == NULL)));
		/* incompatible case, if more than 1 dimension, then dimensions 
 		* have to be provided */

	/* populate meta-data */
	xda->nd = ndims;
	xda->ne = nelem;
	xda->esize = elem_size;

	/* populate dimensions 
 	* several options:
 	* 1) ndims is 1, then disregard external dims array, dims is set to NULL 
 	* 2) ndims > 1, then check the external dims array is consistant with the
 	* number of elements and copy it to the internal dims array */
	
	if (xda->nd == 1)
		xda->dims = NULL;
	else
	{
		/* sanity check on dimension values */
		int d;
		long calc_ne = 1;
		for (d=0; d<ndims; d++)
		{
			assert (dims[d] >= 1); /* each dimension should be at least 1 */
			calc_ne *= (long)dims[d];
		}
		assert (xda->ne == calc_ne);	
			/* number of elements should be consistant with
			* the dimensions provided */ 
		xda->dims = malloc(xda->nd*sizeof(int));
		assert (xda->dims != NULL); /* malloc problem */
		memcpy(xda->dims, dims, xda->nd*sizeof(int));
	}	

	/* populate internal data pointer
 	* several options:
 	* 1) data is NULL, then consider user wants data to be initialized with zeros.
 	* 2) data is valid, then initialize internal data pointer to a copy of the external 
 	* data pointer.
 	* */
	if (data == NULL)
	{
		/* case 1 */
		xda->data = calloc(xda->ne, xda->esize);
		assert (xda->data != NULL); /* malloc problem */
	}
	else
	{
		xda->data = malloc(xda->ne*xda->esize);
		assert (xda->data != NULL); /* malloc problem */
		memcpy(xda->data, data, xda->ne*xda->esize);
	}
}		/* -----  end of function xdarray_init  ----- */


/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  xdarray_init2d
 *  Description:  
 * =====================================================================================
 */
	void
xdarray_init2d ( const void *self, int dim, void *data, size_t elem_size )
{
	xdarray_t *xda = ((xdarray_t*) self);
	int dims[2] = {dim, dim};
	long nelems = (long)dim * (long)dim;
	xda->init(xda, nelems, data, elem_size, 2, dims);
}		/* -----  end of function xdarray_init2d  ----- */


/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  xdarray_init3d
 *  Description:  
 * =====================================================================================
 */
	void
xdarray_init3d ( const void *self, int dim, void *data, size_t elem_size )
{
	xdarray_t *xda = ((xdarray_t*) self);
	int dims[3] = {dim, dim, dim};
	long nelems = (long)dim * (long)dim * (long)dim;
	xda->init(xda, nelems, data, elem_size, 3, dims);
}		/* -----  end of function xdarray_init3d  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  xdarray_size
 *  Description:  
 * =====================================================================================
 */
	long
xdarray_size ( const void *self )
{
	return ((xdarray_t*) self)->ne;
}		/* -----  end of function xdarray_nelems  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  xdarray_memsize
 *  Description:  
 * =====================================================================================
 */
	size_t
xdarray_memsize ( const void *self )
{
	return (size_t)((xdarray_t*) self)->ne * ((xdarray_t*) self)->esize;
}		/* -----  end of function xdarray_memsize  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  xdarray_ndims
 *  Description:  
 * =====================================================================================
 */
	int
xdarray_ndims ( const void *self )
{
	return ((xdarray_t*) self)->nd;
}		/* -----  end of function xdarray_ndims  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  xdarray_dim
 *  Description:  
 * =====================================================================================
 */
	int
xdarray_dim ( const void *self, int ind )
{
	const xdarray_t *xda = ((xdarray_t*) self);
	assert(ind >= 0); /* negative index does not make sense */
	if (xda->dims == NULL) return -1;
	else return (ind < xda->nd)? xda->dims[ind] : 1 ;
}		/* -----  end of function xdarray_dim  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  xdarray_data_rw
 *  Description:  
 * =====================================================================================
 */
	void*
xdarray_data_rw ( const void *self )
{
	return ((xdarray_t*) self)->data;
}		/* -----  end of function xdarray_data_rw  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  xdarray_data_ro
 *  Description:  
 * =====================================================================================
 */
	const void*
xdarray_data_ro ( const void *self )
{
	return (const void *)((xdarray_t*) self)->data;
}		/* -----  end of function xdarray_data_ro  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  xdarray_get
 *  Description:  
 * =====================================================================================
 */
	void*
xdarray_get ( const void *self, long ind )
{
	const xdarray_t *xda = ((xdarray_t*) self);
	return ((ind >= 0) && (ind < xda->ne))? ((char*)xda->data + ind * xda->esize): NULL;
}		/* -----  end of function xdarray_get  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  xdarray_set
 *  Description:  
 * =====================================================================================
 */
	void
xdarray_set ( const void *self, void *dat, long ind )
{
	const xdarray_t *xda = ((xdarray_t*) self);
	if ((ind >= 0) && (ind < xda->ne))
		memcpy(((char*)xda->data + ind * xda->esize), dat, xda->esize);
}		/* -----  end of function xdarray_set  ----- */


/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  xdarray_get2d
 *  Description:  
 * =====================================================================================
 */
	void*
xdarray_get2d ( const void *self, int ix, int iy )
{
	const xdarray_t *xda = ((xdarray_t*) self);
        if (xda->nd < 2) return NULL;
	long ind = (long)ix + (long)iy * (long)xda->dims[0];
	return xda->get(xda, ind);
}		/* -----  end of function xdarray_get2d  ----- */


/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  xdarray_set2d
 *  Description:  
 * =====================================================================================
 */
	void
xdarray_set2d ( const void *self, void *dat, int ix, int iy )
{
	const xdarray_t *xda = ((xdarray_t*) self);
        if (xda->nd < 2) return;
	long ind = (long)ix + (long)xda->dims[0] * (long)iy;
	xda->set(xda, dat, ind);
}		/* -----  end of function xdarray_set2d  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  xdarray_get3d
 *  Description:  
 * =====================================================================================
 */
	void*
xdarray_get3d ( const void *self, int ix, int iy, int iz )
{
	const xdarray_t *xda = ((xdarray_t*) self);
        if (xda->nd < 3) return NULL;
	long ind = (long)ix + (long)xda->dims[0] * ((long)iy + (long)xda->dims[1] * (long)iz);
	return xda->get(xda, ind);
}		/* -----  end of function xdarray_get3d  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  xdarray_set3d
 *  Description:  
 * =====================================================================================
 */
	void
xdarray_set3d ( const void *self, void *dat, int ix, int iy, int iz )
{
	const xdarray_t *xda = ((xdarray_t*) self);
        if (xda->nd < 3) return;
	long ind = (long)ix + (long)xda->dims[0] * ((long)iy + (long)xda->dims[1] * (long)iz);
	xda->set(xda, dat, ind);
}		/* -----  end of function xdarray_set3d  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  new_xdarray
 *  Description:  
 * =====================================================================================
 */
	xdarray_t*
new_xdarray ( void )
{
	xdarray_t *xda = (xdarray_t*)malloc(sizeof(struct xdarray));
	assert (xda != NULL); /* malloc error */
	xda->data = NULL;
	xda->ne = 0;
	xda->esize = 0;
	xda->dims = NULL;
	xda->nd = 0;
	xda->size = &xdarray_size;
	xda->memsize = &xdarray_memsize;
	xda->ndims = &xdarray_ndims;
	xda->dim = &xdarray_dim;
	xda->data_rw = &xdarray_data_rw;
	xda->data_ro = &xdarray_data_ro;
	xda->init = &xdarray_init;
	xda->init2d = &xdarray_init2d;
	xda->init3d = &xdarray_init3d;
	xda->clear = &xdarray_clear;
	xda->get = &xdarray_get;
	xda->set = &xdarray_set;
	xda->get2d = &xdarray_get2d;
	xda->set2d = &xdarray_set2d;
	xda->get3d = &xdarray_get3d;
	xda->set3d = &xdarray_set3d;
	return xda;
}		/* -----  end of function new_xdarray  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  copy_xdarray
 *  Description:  
 * =====================================================================================
 */
	xdarray_t*
copy_xdarray ( const xdarray_t *xda_tocopy )
{
	if (xda_tocopy == NULL) 
		return NULL;
	else
	{
		xdarray_t *xda = new_xdarray();
		assert (xda != NULL);		/* malloc problem */
		xda->init(xda, xda_tocopy->ne, xda_tocopy->data, xda_tocopy->esize,
		xda_tocopy->nd, xda_tocopy->dims);
		return xda;
	}
}		/* -----  end of function copy_xdarray  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  free_xdarray
 *  Description:  
 * =====================================================================================
 */
	void
free_xdarray ( xdarray_t *xda )
{
	if ( xda != NULL )
	{
		free(xda->data);
		free(xda->dims);
		free(xda);
	}
}		/* -----  end of function free_xdarray  ----- */


