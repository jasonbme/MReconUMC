/*
 * =====================================================================================
 *
 *       Filename:  xdarray.h
 *
 *    Description:  
 *
 *        Version:  0.1
 *        Created:  13/05/12 12:43:52
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Ghislain Vaillant (ghislain.vaillant@kcl.ac.uk) 
 *   Organization:  King's College London
 *
 * =====================================================================================
 */

#ifndef XDARRAY_H
#define XDARRAY_H

/* INCLUDES */
#include <stdlib.h>

/* STRUCT */
typedef struct xdarray {
	/* members */
	void *data;
	long ne;
	size_t esize;
	int *dims;
	int nd;
	/* getters */
	long (*size)(const void*);
	size_t (*memsize)(const void*);
	int (*ndims)(const void*);
	int (*dim)(const void*, int);
	const void* (*data_ro)(const void*);
	void* (*data_rw)(const void*);
	/* initializers */
	void (*init)(const void*, long, void*, size_t, int, int*);
	void (*init2d)(const void*, int, void*, size_t);
	void (*init3d)(const void*, int, void*, size_t);
        /* clear */
        void (*clear)(const void*);
	/* indexed data getter and setter */
	void* (*get)(const void*, long);
	void (*set)(const void*, void*, long);
	/* multi-dimensional getters and setters */
	void* (*get2d)(const void*, int, int);
	void (*set2d)(const void*, void*, int, int);
	void* (*get3d)(const void*, int, int, int);
	void (*set3d)(const void*, void*, int, int, int);
} xdarray_t;

/* METHODS */
/* constructors and destructors */
xdarray_t* new_xdarray(void);
xdarray_t* copy_xdarray(const xdarray_t*);
void free_xdarray(xdarray_t*);

#endif
