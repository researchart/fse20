clear all
close all
temp_t = datetime('now');
rng(int32(temp_t.Hour*10000+temp_t.Minute*100+temp_t.Second));

while (1)
    clear all;
    try
        rrt_4_way_intersection;
    catch
        disp('exception')
    end
end
