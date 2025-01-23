#include <math.h>
#include <mex.h>



//Matlab is column indexing
int index(const int *ps, int i,int j, int k)
{return (k-1)*ps[1]*ps[0]+(j-1)*ps[0]+i-1;}


void mexFunction(int nlhs,       mxArray *plhs[],
				int nrhs, const mxArray *prhs[])
{
	double *psi, *pimgsi, *pso, *pmvxl2lph;
	int	interpm;
	int size_i[3];
	int i,j,k;
	psi	=mxGetPr(prhs[0]);
	for (i=0;i<3;i++)
		size_i[i]=(int)psi[i];
	pimgsi	=mxGetPr(prhs[1]);
	pmvxl2lph	=mxGetPr(prhs[2]);
	bool bvxlw =(bool)mxGetScalar(prhs[3]);
	double vxlth =mxGetScalar(prhs[4]);


	plhs[0]=mxCreateDoubleMatrix(4, 1, mxREAL);
	double *pval=mxGetPr(plhs[0]);
	pval[3]=1.;
	int indi;
	double lph[4],vxl[4];
	int count=0;
	double swt=0.;
	double sum_lph[3];
	int ii,jj;
	for (i=0;i<3;i++)
		sum_lph[i]=0.;

	for (k=1;k<size_i[2];k++)
	for (i=1;i<size_i[0];i++)
	for (j=1;j<size_i[1];j++)
	{
		indi=index(size_i,i,j,k);
		if (pimgsi[indi]>vxlth)
		{
			vxl[0]=i;vxl[1]=j;vxl[2]=k;vxl[3]=1.;
			for (ii=0;ii<4;ii++)
			{
				lph[ii]=0;
				for (jj=0;jj<4;jj++)
					lph[ii]=lph[ii]+pmvxl2lph[jj*4+ii]*vxl[jj];
			}	

			if (bvxlw)
			{
				swt+=pimgsi[indi];
				for (ii=0;ii<3;ii++)
					sum_lph[ii]+=pimgsi[indi]*lph[ii];
				count++;
			}
			else
			{
				for (ii=0;ii<3;ii++)
					sum_lph[ii]+=lph[ii];
				count++;
			}

		}

	}
	//mexPrintf("\n cout=%i",count);
	//mexPrintf("\n swt=%f",swt);
	//mexPrintf("\n sum_lph=%f %f %f" ,sum_lph[0], sum_lph[1], sum_lph[2]);
	if (bvxlw)
	{
		//mexPrintf("\n pval=%f %f %f" ,pval[0], pval[1], pval[2]);
		for (ii=0;ii<3;ii++)
			pval[ii]=sum_lph[ii]/swt;
		//mexPrintf("\n pval=%f %f %f" ,pval[0], pval[1], pval[2]);
	}
	else
	{
		for (ii=0;ii<3;ii++)
			pval[ii]=sum_lph[ii]/count;
	}
	return;

}
