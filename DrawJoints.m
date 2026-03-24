function DrawJoints(points2D, epilines, vueCalib)
    hold on;
    % Get the number of available points
    n = size(points2D, 2);
    for i = 1 : n
        k = max(vueCalib.prinpoint) * 2;
        x = [points2D(1,i) - k * epilines(1,i), points2D(1,i), points2D(1,i) + k * epilines(1,i)];
        y = [points2D(2,i) - k * epilines(2,i), points2D(2,i), points2D(2,i) + k * epilines(2,i)];
        plot(x, y, '-o', 'MarkerSize', 8, 'LineWidth', 1.4);
    end
    hold off;
end