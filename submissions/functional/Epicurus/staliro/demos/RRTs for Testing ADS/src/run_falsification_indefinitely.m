clear all
close all
temp_t = datetime('now');
rng(int32(temp_t.Hour*10000+temp_t.Minute*100+temp_t.Second));

while (1)
    clear all;
    try
        generate_test_falsification;
    catch
        disp('exception')
    end
end
