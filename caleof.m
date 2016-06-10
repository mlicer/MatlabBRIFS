%   [EOFs,PC,EXPVAR] = CALEOF(M,N,METHOD) Compute EOF
% [EOFs,PC,EXPVAR] = CALEOF(M,N,METHOD) Compute EOF
%
% => Compute the Nth first EOFs of matrix M(TIME,MAP).
% EOFs is a matrix of the form EOFs(N,MAP), PC is the principal
% components matrix ie it has the form PC(N,TIME) and EXPVAR is
% the fraction of total variance "explained" by each EOF ie it has
% the form EXPVAR(N).
% Differents method can be used:
% 1 - The "classic" one, ie we compute eigenvectors of the 
%     temporal covariance matrix with the eig Matlab function.
% 2 - A faster "classic" one, same as method 1 but we use the
%     eigs Matlab function.
% 3 - We compute eigenvectors by the singular value decomposition,
%     by used of the svd Matlab function.
% 4 - Same as method 3 but faster by used of the svds Matlab function
%
% See also EIG, EIGS, SVD, SVDS
%
% Ref: L. Hartmann: "Objective Analysis" 2002
% Ref: H. Bjornson and S.A. Venegas: "A manual for EOF and SVD - 
%      Analyses of climatic Data" 1997
%================================================================

%  Guillaume MAZE - LPO/LMD - March 2004
%  gmaze@univ-brest.fr


function [e,pc,expvar,L] = caleof(M,N,method);

% Get dimensions
[n p]=size(M);

% Temporal covariance is p*p matrix, that why max EOF computable is p, 
% so we perform a test on parameter N:
if(N>p)
 disp('Warning: N is larger than possible so it''s modified to perform')
 disp('         EOFs computing...');
 N = p; 
end


% Eventualy time filtering of data
if 0==1
   disp('====> Time filtering...')
   Fc  = 1/20; Fc2 = 1/1;
   Fc  = 1/7 ; Fc2 = 1/3;
   SIGNAL = M(:,1);
   nj = fix(length(SIGNAL)/10); % Nombre de points du filtre
   for ipt = 1 : p
       SIGNAL = M(:,ipt);
       SIGNALF = lanczos(SIGNAL,Fc2,nj);
       SIGNALF = SIGNALF - lanczos(SIGNALF,Fc,nj);
       Y(:,ipt) = SIGNALF;
   end
   M = Y;
end


disp('      Computing EOFs ...')
switch method
    case 1 % CLASSIC METHOD
%================================================================
% Transform the data matrix in the correct form (map*time)
M=M';

% Remove the time mean (ie the mean of each rows of M)
% Rq: detrend remove the mean of columns ie we take M'.
F=detrend(M','constant')';

% Covariance Matrix (inner product over space = covariance in time)
R = F*F';

% Eigenanalysis of the square covariance matrix
[E,L] = eig(R);

% Get PC by projecting eigenvectors on original data
Z = E'*F;

% Make them clear for output
for iN=1:N
    e(iN,:) = squeeze( E(:,p-(iN-1)) )';
   pc(iN,:) = squeeze( Z(p-(iN-1),:) );
end

% Amount of explained variance (at 0.1%)
dsum=diag(L)./trace(R);
for iN=1:N
   expvar(iN)=fix((dsum(p-(iN-1))*100/sum(dsum))*10)/10;
%   expvar(iN)=dsum(p-(iN-1));
end

% Plots Original field and reconstructed one
if 0==1
figure;
subplot(1,2,1);imagesc(abs(M));title('ORIGINAL');cx=caxis;
%subplot(1,2,2);imagesc((E*Z));title('RECONSTRUCTED')
subplot(1,2,2);imagesc(abs(e'*pc));title('RECONSTRUCTED');caxis(cx);
end

    case 2 % RAPID CLASSIC METHOD 
%================================================================
% Transform the data matrix in the correct form (map*time)
M=M';

% Remove the mean of each column
F=detrend(M,'constant');

% Covariance Matrix
R = F*F';

% Eigenanalysis of the square covariance matrix
[E,L] = eigs(R,N);

% Get PC by projecting eigenvectors on original data
Z = E'*F;

% Make them clear for output
for iN=1:N
    e(iN,:) = squeeze( E(:,iN) )';
   pc(iN,:) = squeeze( Z(iN,:) );
end

% Amount of variance explained a 0.1 pres et en %
dsum=diag(L)./trace(R);
for iN=1:N
   expvar(iN)=fix((dsum(iN)*100/sum(dsum))*10)/10;
end


    case 3 % SVD METHOD
%================================================================
% Ref: H. Bjornson and S.A. Venegas: "A manual for EOF and SVD - 
% Analyses of climatic Data" 1997 => p18

% Assume that M is (time*map) matrix
[n p]=size(M);

% Remove the mean of each column (ie the time mean in each station records)
F=detrend(M,'constant');

% Find eigenvectors and singular values
[C,L,CC] = svd(F);
% Eigenvectors are in CC and the squared diagonal values of L
% are the eigenvalues of the temporal covariance matrix R=F'*F

% find the PC corresponding to eigenvalue
PC = F*CC;

% Make them clear for output
for iN=1:N
    e(iN,:) = squeeze( CC(:,iN) )';
   pc(iN,:) = squeeze( PC(:,iN) )';
end

% Amount of variance explained a 0.1 pres et en %
dsumSQ=diag(L.^2)./trace(L.^2);
dsum=diag(L)./trace(L);
for iN=1:N
   expvar(iN)=fix( ( dsum(iN)*100/sum(dsum) )*10 ) /10;
end

figure;
subplot(1,2,1);imagesc(M);title('ORIGINAL');cx=caxis;
subplot(1,2,2);imagesc((e'*pc)');title('RECONSTRUCTED');caxis(cx);



    case 4 % FAST SVD METHOD
%================================================================
% Ref: H. Bjornson and S.A. Venegas: "A manual for EOF and SVD - 
% Analyses of climatic Data" 1997 => p18

% Assume that M is (time*map) matrix
[n p]=size(M);

% Remove the mean of each column (ie the time mean in each station records)
F=detrend(M,'constant');

% Find eigenvectors and singular values
[C,L,CC] = svds(F,N);
% Eigenvectors are in CC and the squared diagonal values of L
% are the eigenvalues of the temporal covariance matrix R=F'*F

% find the PC corresponding to eigenvalue
PC = F*CC;

% Make them clear for output
for iN=1:N
    e(iN,:) = squeeze( CC(:,iN) )';
   pc(iN,:) = squeeze( PC(:,iN) )';
end

% Amount of variance explained a 0.1 pres et en %
dsumSQ=diag(L.^2)./trace(L.^2);
dsum=diag(L)./trace(L);
for iN=1:N
   expvar(iN)=fix( ( dsum(iN)*100/sum(dsum) )*10 ) /10;
end

%figure;
%subplot(1,2,1);imagesc(M);title('ORIGINAL');cx=caxis;
%subplot(1,2,2);imagesc((e'*pc)');title('RECONSTRUCTED');caxis(cx);


end % switch method
%disp('====> Finished !')