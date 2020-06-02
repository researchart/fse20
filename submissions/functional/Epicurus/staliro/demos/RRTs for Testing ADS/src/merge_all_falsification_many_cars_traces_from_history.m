
path_to_files = '../log/';
falslist_files = dir([path_to_files, 'falsification_many_cars_*.mat']);
all_fals_XT = [];
for ffile_i = 1:length(falslist_files)
    loadfilename = falslist_files(ffile_i).name;
    load([path_to_files, loadfilename]);

    best_cost = results.run.bestCost;
    best_ind = find(history.cost == best_cost, 1);
    assert(~isempty(best_ind), 'Best experiment could not be found');

    XT = history.traj{best_ind};
    all_fals_XT = [all_fals_XT; XT];
    if ~isempty(find(XT(:,7)<3.5))
        ffile_i
        loadfilename
    end
end

all_fals_traj = all_fals_XT(:,[1:3,6:8,10:12,14:16,18:20]);
%all_fals_traj(:,1:3) = convert_x_to_webots(all_fals_traj(:,1:3));
%all_fals_traj(:,4:6) = convert_x_to_webots(all_fals_traj(:,4:6));
%all_fals_traj(:,7:9) = convert_x_to_webots(all_fals_traj(:,7:9));
%all_fals_traj(:,10:12) = convert_x_to_webots(all_fals_traj(:,10:12));
%all_fals_traj(:,13:15) = convert_x_to_webots(all_fals_traj(:,13:15));
