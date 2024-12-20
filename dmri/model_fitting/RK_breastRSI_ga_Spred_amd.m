function [pred aic beta] = RK_breastRSI_ga_Spred(x, temp, nonnegflag)
	% temp is a structure with the fields: 
	% bvals - b-values 
	% Sobs - observed signal intensities [number of bvals x number of samples]
	% returns:
	% 

        if ~exist('nonnegflag','var')
           nonnegflag = true;
        end

	if ~isfield(temp, 'bvals')
	error(sprintf('%s - Error! bvals is not defined!\n', mfilename)); 
	end
	if ~isfield(temp, 'Sobs');
	error(sprintf('%s - Error! Sobs is not defined!\n', mfilename)); 
	end
	if ~isfield(temp, 'tol')
	temp.tol = 0; 
	end

	bvals = temp.bvals; Sobs = temp.Sobs; tol = temp.tol;
	A = [];
	for id1 = 1:numel(x)
	  A = cat(2,A, reshape(exp(-bvals.*x(id1)), [],1));
	end
	if nonnegflag
          beta = lsqnonneg_amd(A,Sobs);
	else 
          beta = pinv(A)*Sobs;
        end

	pred = A*beta; 
	cost = sum(mean((pred - Sobs).^2, 1)./mean(Sobs,1), 2); 
	rss = sum((pred - temp.Sobs).^2, 1);
	numComp = length(x); 
	aic = 2*numComp + 4*log(rss./4) + (2*numComp*(numComp+1))./(4-numComp-1); % Not sure this is correct

if 0
        resmat_bak = A*beta_bak - Sobs;
        resmat = A*beta - Sobs;
        figure(666); subplot(2,2,1); plot(beta(1,:)-beta_bak(1,:)); subplot(2,2,2); plot(beta(2,:)-beta_bak(2,:)); subplot(2,2,3); plot(beta(3,:)-beta_bak(3,:)); subplot(2,2,4); plot(sqrt(sum(resmat.^2,1))-sqrt(sum(resmat_bak.^2,1)));
        [sv si] = sort(sqrt(sum(resmat.^2,1))-sqrt(sum(resmat_bak.^2,1)),'descend');
        ii = si(1);
        beta(:,ii)'
        beta_bak(:,ii)'
        beta_tmp = A(:,1:2)\Sobs(:,ii); % Works -- change code to fit for all combinations of non-zero
end

return 

% Look at where and how solutions differ
%   Associated with higher or lower cost / residuals?

