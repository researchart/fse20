% Create a video writer object
writerObj = VideoWriter('Video-scn-10-11-lat_long_safety.avi');

% Set frame rate
writerObj.FrameRate = 10;

% Open video writer object and write frames sequentially
open(writerObj)

for i = 1:74                   % Some number of frames
     % Read frame
     frame = sprintf('FIG%d.png', i);
     input = imread(frame);

     % Write frame now
     writeVideo(writerObj, input);
end

% Close the video writer object
close(writerObj);