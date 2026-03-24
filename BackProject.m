function rays3D = BackProject(points2D, vueCalib)
    % Get the number of points
    n = size(points2D, 2);
    
    % Augment the points matrix
    aPoints2D = [points2D; ones(1, n)];
    
    % Compute the rays
    rays3D = inv(vueCalib.Rmat) * inv(vueCalib.Kmat) * aPoints2D;
    
    % Normalize all the rays
    rays3D = rays3D ./ repmat(vecnorm(rays3D), 3, 1);
end