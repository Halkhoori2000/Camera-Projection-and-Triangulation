function [points2D1, points2D2, rays3D1, rays3D2, frameTriangulated, epilines1, epilines2] = ProcessFrame(frame, vueCalib1, vueCalib2)
    x = frame(1,:,1); % array of 12 X coordinates
    y = frame(1,:,2); % Y coordinates
    z = frame(1,:,3); % Z coordinates
    
    % Get the number of points
    n = size(x, 2);

    % Combine points into a matrix 
    P = [x; y; z];
    
    % Compute the 2d coordinates on the image
    points2D1 = Project(P, vueCalib1, true);
    points2D2 = Project(P, vueCalib2, true);
    
    % Compute the rays based on the 2d coords
    rays3D1 = BackProject(points2D1, vueCalib1);
    rays3D2 = BackProject(points2D2, vueCalib2);
    
    % Triangulate
    frameTriangulated = Triangulate(rays3D1, rays3D2, vueCalib1.position', vueCalib2.position');

    % Project the center of other camera into an image point to get the
    % epipoles and subtract it with the points to get the epilines 
    epipoles1 = repmat(Project(vueCalib2.position', vueCalib1, false), 1, n);
    epipoles2 = repmat(Project(vueCalib1.position', vueCalib2, false), 1, n);
    epilines1 = epipoles1 - points2D1;
    epilines2 = epipoles2 - points2D2;
end