yn=input('Did you run Demo_S_Taliro_wihtout_intersection.m before this? 0) No  1) Yes ');
if yn==1
    fprintf('Choose vehicle number between 1 and %d\n',length(obstacleLane));
    on=input('');
    if on<1 || on>length(obstacleLane)
        error('Obstacle number is wrong');
    end
    figure(4);
    hold on;
    axis equal;
    x=perception.map.obstacles(on).trajectory.position(1,:);
    y=perception.map.obstacles(on).trajectory.position(2,:);
    plot(x,y,'square');
%     r = antenna.Rectangle;
%     for i=1:length(x)
%         
%     end
    if isscalar(obstacleLane{on})
        ln=obstacleLane{on};
        lb=perception.map.lanes(ln).leftBorder.vertices;
        rb=perception.map.lanes(ln).rightBorder.vertices;
        plot(lb(1,:),lb(2,:),'k');
        plot(rb(1,:),rb(2,:),'k');
        c=perception.map.lanes(ln).center.vertices;
        plot(c(1,:),c(2,:),'g');
        pz=size(obstaclePoint{on});
        for j=1:pz(2)
            plot(obstaclePoint{on}(1,j),obstaclePoint{on}(2,j),'*r');
            plot([obstaclePoint{on}(1,j),x(j)],[obstaclePoint{on}(2,j),y(j)],'r');
            
        end
    else
        sz=size(obstacleLane{on});
        for i=1:sz(1)
            ln=obstacleLane{on}(i,1);
            lb=perception.map.lanes(ln).leftBorder.vertices;
            rb=perception.map.lanes(ln).rightBorder.vertices;
            plot(lb(1,:),lb(2,:),'k');
            plot(rb(1,:),rb(2,:),'k');
            c=perception.map.lanes(ln).center.vertices;
            plot(c(1,:),c(2,:),'g');
            pz=size(obstaclePoint{on}{i});
            for j=1:pz(2)
                plot(obstaclePoint{on}{i}(1,j),obstaclePoint{on}{i}(2,j),'*r');
                plot([obstaclePoint{on}{i}(1,j),x(j+obstacleLane{on}(i,2)-1)],[obstaclePoint{on}{i}(2,j),y(j+obstacleLane{on}(i,2)-1)],'r');
            end

        end
    end
end