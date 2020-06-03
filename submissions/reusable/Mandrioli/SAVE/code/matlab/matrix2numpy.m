function res = matrix2numpy(A)
    [r,c] = size(A);
    res = 'np.matrix([';
    for i=1:r
        res = [res '['];
        for j=1:c
            res = [res sprintf('%g',A(i,j))];
            if j<c
                res = [res ','];
            end
        end
        res = [res ']'];
        if i<r
            res = [res ','];
        end
    end
    res = [res '])'];
end