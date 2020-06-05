function r = ur_sample_from_space(sample_space)
    %rand_between Returns a random number between a and b.
    a = sample_space(:,1);
    b = sample_space(:,2);
    r = (b-a).*rand(size(b)) + a;
end
