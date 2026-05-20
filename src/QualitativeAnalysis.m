function QualitativeAnalysis(mocapFnum, vueVideo1, vueVideo2, points1, points2, epilines1, epilines2, vueCalib1, vueCalib2, triangulations)
    % Get the frame 
    vueVideo1.CurrentTime = (mocapFnum-1)*(50/100)/vueVideo1.FrameRate;
    vid2Frame = readFrame(vueVideo1);

    % Get the frame 
    vueVideo2.CurrentTime = (mocapFnum-1)*(50/100)/vueVideo2.FrameRate;
    vid4Frame = readFrame(vueVideo2);

    % Show the frame and plot the projection on top of it
    figure;
    imshow(vid2Frame);
    DrawJoints(squeeze(points1(mocapFnum, :, :)), squeeze(epilines1(mocapFnum, :, :)), vueCalib1);
    title(sprintf('Frame: %d', mocapFnum));

    % Show the frame and plot the projection on top of it
    figure;
    imshow(vid4Frame);
    DrawJoints(squeeze(points2(mocapFnum, :, :)), squeeze(epilines2(mocapFnum, :, :)), vueCalib2);
    title(sprintf('Frame: %d', mocapFnum));
    
    % Draw the skeletons
    figure;
    imshow(vid2Frame);
    DrawSkeleton(squeeze(points1(mocapFnum, :, :)), [0 1 0]);
    title(sprintf('Frame: %d', mocapFnum));
    
    figure;
    imshow(vid4Frame);
    DrawSkeleton(squeeze(points2(mocapFnum, :, :)), [0 1 0]);
    title(sprintf('Frame: %d', mocapFnum));
    
    % Draw the skeletons with predicted
    tr = squeeze(triangulations(mocapFnum, :, :));
    trPoints2D1 = Project(tr, vueCalib1, false);
    trPoints2D2 = Project(tr, vueCalib2, false);
    
    figure;
    imshow(vid2Frame);
    DrawSkeleton(squeeze(points1(mocapFnum, :, :)), [0 1 0]);
    DrawSkeleton(trPoints2D1, [1 0 0]);
    title(sprintf('Frame: %d', mocapFnum));
    
    figure;
    imshow(vid4Frame);
    DrawSkeleton(squeeze(points2(mocapFnum, :, :)), [0 1 0]);
    DrawSkeleton(trPoints2D2, [1 0 0]);
    title(sprintf('Frame: %d', mocapFnum));

end