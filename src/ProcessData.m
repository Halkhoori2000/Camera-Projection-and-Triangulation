function [points1, points2, rays1, rays2, triangulations, epilines1, epilines2, L2] = ProcessData(mocapJoints, vueCalib1, vueCalib2)
    % Process the computations here 
    frames = size(mocapJoints, 1);
    joints = size(mocapJoints, 2);

    % Allocate matrices to store the results 
    points1 = zeros(frames, 2, joints);
    points2 = zeros(frames, 2, joints);
    rays1 = zeros(frames, 3, joints);
    rays2 = zeros(frames, 3, joints);
    triangulations = zeros(frames, 3, joints);
    epilines1 = zeros(frames, 2, joints);
    epilines2 = zeros(frames, 2, joints);
    L2 = zeros(frames, joints);

    for f = 1 : frames
        [p1, p2, r1, r2, ft, el1, el2] = ProcessFrame(mocapJoints(f, :, :), vueCalib1, vueCalib2);

        % Store the results
        points1(f, :, :) = p1;
        points2(f, :, :) = p2;
        rays1(f, :, :) = r1;
        rays2(f, :, :) = r2;
        triangulations(f, :, :) = ft;
        epilines1(f, :, :) = el1;
        epilines2(f, :, :) = el2;

        % Compute the L2 errors
        L2(f, :) = vecnorm(squeeze(mocapJoints(f, :, 1:3))' - ft);
    end
end