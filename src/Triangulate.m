function points3D = Triangulate(rays1, rays2, position1, position2)
    % Formula based on https://piepieninja.github.io/2020/04/29/2-view-triangulation/
    % Get the number of pairs of rays to triangulate
    n = size(rays2, 2);
    
    % Get normals
    n1 = cross(rays2, cross(rays1, rays2, 1), 1); 
    n2 = cross(rays1, cross(rays2, rays1, 1), 1); 
    
    % Get the positions 
    pos1 = repmat(position1, 1, n);
    pos2 = repmat(position2, 1, n);
    
    % Compute the end points of rays near the intersection
    s1 =  pos1 + dot(pos2 - pos1, n1, 1) ./ dot(rays1, n1, 1) .* rays1;
    s2 =  pos2 + dot(pos1 - pos2, n2, 1) ./ dot(rays2, n2, 1) .* rays2;
    
    % Get the midpoint of the endpoints
    points3D = (s1 + s2) / 2;
end