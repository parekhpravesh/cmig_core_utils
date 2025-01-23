#include <mex.h>
#include "../resliceMEX/getvxlval.h"

void mexFunction(int nlhs,       mxArray *plhs[],
				int nrhs, const mxArray *prhs[])
{
	double *plph, *psi, *pimgs_i, *pmlph2vxl;
	int	interpm;
	int 	padding;
	int size_i[3];
	int i;

	plph  =mxGetPr(prhs[0]);
	psi	=mxGetPr(prhs[1]);
	for (i=0;i<3;i++)
		size_i[i]=(int)psi[i];
	pimgs_i	 =mxGetPr(prhs[2]);
	pmlph2vxl =mxGetPr(prhs[3]);
	interpm  =(int)mxGetScalar(prhs[4]);
	padding = (int)mxGetScalar(prhs[5]);

	int N=mxGetM(prhs[0]);
	plhs[0]=mxCreateDoubleMatrix(N, 1, mxREAL);
	double *pval=mxGetPr(plhs[0]);
    plhs[1]=mxCreateDoubleMatrix(N, 1, mxREAL);
	double *pInBound=mxGetPr(plhs[1]);
    
	double lpho[4];
	for (i=0;i<N;i++)
	{
		lpho[0]=plph[i];
		lpho[1]=plph[i+N];
		lpho[2]=plph[i+2*N];
		lpho[3]=1.;
		pInBound[i]=getvxlval(lpho, size_i, pimgs_i, pmlph2vxl, interpm,padding, pval[i]);
	}
	

	

}
