function w = learn_kernel_reg(X, Y, lambda)


w = (X*X'+lambda*eye(size(X,1))) \ (X*Y');