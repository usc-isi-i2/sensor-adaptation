function [currentP, currentVal, currentGrad, Minv, allP] = optimizeOrtho(f, P0, stopThresh, maxiter, armijo, verbose)
% optimizeOrtho(f, P0) minimizes the objective function f(P) where
% P is an orthogonal matrix: P'*P = I_d where P is a matrix of (m x d).
% Namely, P is on the Stiefel manifold
% 
% this algorithm implements steepest gradient descent with (Armijo) line
% search, starting with initial value P0
%
% f() should be a function handler such that @f(P) returns two numbers:
% f(P) and f'(P) where f'(P) is the gradient at P in the Euclidean space
%
% Note that we return currentGrad as the gradient on the manifold.
%
%

%ARMIJO_SIGMA = 1e-2;
if nargin == 4
    ARMIJO_SIGMA = 1e-6;
    ARMIJO_BETA  = 1/2;
    ARMIJO_INITSTEP = 0.1;
    verbose = 1;
end
if nargin >=5
    ARMIJO_SIGMA = armijo.SIGMA;
    ARMIJO_BETA  = armijo.BETA;
    ARMIJO_INITSTEP = armijo.INITSTEP;
end
if nargin <6
    verbose = 1;
end
[currentVal, currentEuclideanGrad, Minv] = f(P0);
currentP  = P0;
if verbose == 1
    fprintf('iter:%d, obj:%e\n', 0, currentVal);
end
try_init_step = ones(10,1)*ARMIJO_INITSTEP;
for iter = 1: maxiter
    
    currentGrad = currentEuclideanGrad - currentP*(currentEuclideanGrad'*currentP);
    A = -currentP'*currentGrad ; 
    projGrad= -currentGrad - currentP*A;
    
    % QR decomposition
    [Q, R] = qr(projGrad, 0);
    
    % eigendecompose
    S = [A -R'; R zeros(size(R,1), size(R,1))];

     if sum( sum(isnan(S) )) > 0 | sum( sum(isinf(S) ))
        keyboard;
     end

    [V, E] = eig(S); E= diag(E);
    
    % line search
    % reduction amount, we need to compute it on Stiefel manifold
    % ie. measuring using the manifold's canonical metric
    %reduceAmt = trace(currentGrad'*(eye(size(currentP,1))-1/2*currentP*currentP')*currentGrad);
    %reduceAmt = trace(currenntGrad'*currentGrad - 1/2*A'*A);
    reduceAmt = currentGrad(:)'*currentGrad(:) - 1/2*A(:)'*A(:);
    
    stepsize = ARMIJO_INITSTEP;
    oldval = currentVal;
    while stepsize > eps
        % search direction
        tempT = real(V* diag(exp(stepsize*E))*inv(V));
        % transport the tangent vector
        Et = tempT(1:size(P0,2),1:size(P0,2));
        Ft = tempT(size(P0,2)+1:end, 1:size(P0,2));
        new_P = currentP*Et + Q*Ft;
        if any(isnan(new_P(:))) 
            stepsize = stepsize*ARMIJO_BETA;
            try_init_step = [try_init_step(2:end); stepsize];
            continue;
        end
        [newVal, newEuclideanGrad, Minv] = f(new_P);
        
        if verbose == 2
            fprintf('\tstepsize: %e, obj: %e, accept ratio: %e\n', stepsize, newVal, (currentVal - newVal)/(ARMIJO_SIGMA*stepsize*reduceAmt) );
        end
        if newVal > currentVal
           stepsize = stepsize*ARMIJO_BETA;
           try_init_step = [try_init_step(2:end); stepsize];
           continue;
        end
        if currentVal - newVal >= ...
                ARMIJO_SIGMA*stepsize*reduceAmt
            currentVal = newVal;
            currentEuclideanGrad = newEuclideanGrad;
            currentP = new_P;
            allP{iter} = currentP;
            % being adaptive
            ARMIJO_INITSTEP = stepsize/ARMIJO_BETA; % readjust initstepsize to current step size increased slightly
            break;
        else
            stepsize = stepsize*ARMIJO_BETA;
            try_init_step = [try_init_step(2:end); stepsize];
        end
    end
    if verbose == 1 %& rem(iter, 5)==1
        fprintf('iter:%d, obj:%e\n', iter, currentVal);
    end
    if abs(currentVal- oldval) <= stopThresh*abs(oldval)
        if verbose == 1
            fprintf('Stop criteria met!\n');
        end
        break;
    end
    if iter >= maxiter
        if verbose == 1
            fprintf('Max # of iteration reached\n');
        end
        break;
    end
end