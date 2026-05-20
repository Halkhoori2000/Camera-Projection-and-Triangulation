function points2D = Project(points3D, vueCalib, correctNL)
    % Transform point3D to optical coordinate system -> tPoint3D
    % Based on http://epixea.com/research/multi-view-coding-thesisch2.html#:~:text=The%20pinhole%20camera%20model%20defines,is%20called%20a%20perspective%20projection.
    % Pmat = Rtrans * Ctrans
    % Get the number of points
    n = size(points3D, 2);
    
    % Augment the points3D
    aPoints3D = [points3D; ones(1, n)];
    
    % Transform the point to camera coordinates
    tPoints3D = [vueCalib.Pmat; 0 0 0 1] * aPoints3D;
    
    % Apply projection 
    CamTrans = [vueCalib.Kmat zeros(3, 1)];
    
    % Project the transformed 3d point to 2d
    tPoints2D = CamTrans * tPoints3D;
    
    % Extract the result 
    points2D(1,:) = tPoints2D(1, :) ./ tPoints2D(3, :);
    points2D(2,:) = tPoints2D(2, :) ./ tPoints2D(3, :);
       
    if correctNL
        % Apply non-linear distortion correction 
        o = repmat(vueCalib.prinpoint', 1, n);
        r = vecnorm(points2D - o);
        k = vueCalib.radial; 

        % Compute the correction
        % Based on https://en.wikipedia.org/wiki/Distortion_(optics)#Radial_distortion
        % xu = xd - (xd - ox)(k1 * r^2 + k2 * r^4)
        corr = (points2D - o) .* repmat((k(1) * r.^2) + (k(2) * r.^4), 2, 1);

        points2D = points2D - corr;
    end
        
    % Optical coordinate system: 
    %   - origin behind center of image plane (distance = focal length)
    %   - x axis horizontal (positive right facing from camera to object)
    %   - y axis vertical (positive down facing from camera to object)
    %   - image plane is perpendicular to z axis 
    % Compute (u, v) coordinates from tPoint3D
    % lambda(u v 1)T = (f 0 0 0; 0 f 0 0; 0 0 1 0) (X Y Z 1)T
    % where lambda = Z
    % if the origin of the image is at the top left
    % lambda(x y 1)T = (f 0 ox 0; 0 f oy 0; 0 0 1 0) (X Y Z 1)T
    % 
    
end