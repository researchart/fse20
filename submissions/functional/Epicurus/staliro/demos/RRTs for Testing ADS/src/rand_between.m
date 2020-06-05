function r = rand_between(a, b)
    %rand_between Returns a random number between a and b.
    if nargin == 1
        if length(a) == 2
            b = a(2);
            a = a(1);
        else
            b = a;
        end
    end
    if b < a
        temp = a;
        a = b;
        b = temp;
    end
    r = (b-a).*rand(size(b)) + a;
end