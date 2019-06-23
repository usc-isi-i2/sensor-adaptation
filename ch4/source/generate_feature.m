function new_X = generate_feature(X, degree)


if degree == 1
    new_X = X;
elseif degree == 2
    new_X = X;
    
    D = size(X,1);
    
    for i = 1:D
        for j = i:D
            new_X = [new_X; X(i,:).*X(j,:)];
        end
    end
elseif degree == 3
    new_X = X;
    
    D = size(X,1);
    
    for i = 1:D
        for j = i:D
            new_X = [new_X; X(i,:).*X(j,:)];
        end
    end
    
    for i = 1:D
        for j = i:D
            for k = j:D
                new_X = [new_X; X(i,:).*X(j,:).*X(k,:)];
            end
        end
    end
end