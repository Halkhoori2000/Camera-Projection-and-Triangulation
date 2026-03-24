function DrawSkeleton(points, color)
    % Draw on the current axis
    hold on
    
    % Build the limbs
    right_arm = points(:, 1:3);
    left_arm = points(:, 4:6);
    right_leg = points(:, 7:9);
    left_leg = points(:, 10:12);
    shoulder = points(:, [7, 10]);
    hip = points(:, [1, 4]);
    spine = [(points(:,1) + points(:,4)) / 2, (points(:,7) + points(:,10)) / 2];
    
    % Draw limbs
    plot(right_arm(1,:), right_arm(2,:), 'Marker', 'o', 'Color', color, 'LineWidth', 1.4);
    plot(left_arm(1,:), left_arm(2,:), 'Marker', 'o', 'Color', color, 'LineWidth', 1.4);
    plot(right_leg(1,:), right_leg(2,:),'Marker', 'o', 'Color', color, 'LineWidth', 1.4);
    plot(left_leg(1,:), left_leg(2,:), 'Marker', 'o', 'Color', color, 'LineWidth', 1.4);
    plot(shoulder(1,:), shoulder(2,:), 'Marker', 'o', 'Color', color, 'LineWidth', 1.4);
    plot(hip(1,:), hip(2,:), 'Marker', 'o', 'Color', color, 'LineWidth', 1.4);
    plot(spine(1,:), spine(2,:), 'Marker', 'o', 'Color', color, 'LineWidth', 1.4);
    
    hold off
end