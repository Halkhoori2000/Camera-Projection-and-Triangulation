function QuantitativeAnalysis(mocapJoints, L2)
    % Get the number of frames
    frames = size(mocapJoints, 1);
    
    % Filter the frames with all 12 joints valid
    allValidJoints = sum(mocapJoints(:,:,4), 2) == 12;

    % (1) For each of the twelve joint pairs, provide the mean, std, minimum,
    % median, and maximum over the
    % Compute the statistics here 
    fprintf(1, 'Quantitative Analysis:\n');
    fprintf(1, 'For each of the twelve joint pairs:\n');
    fprintf(1, 'Mean:\n');
    disp(mean(L2(allValidJoints, :), 1));
    fprintf(1, 'Standard Deviation:\n');
    disp(std(L2(allValidJoints, :), 1));
    fprintf(1, 'Median:\n');
    disp(median(L2(allValidJoints, :), 1));
    fprintf(1, 'Minimum:\n');
    disp(min(L2(allValidJoints, :), [], 1));
    fprintf(1, 'Maximum:\n');
    disp(max(L2(allValidJoints, :), [], 1));

    % (2) For all joint pairs (independent of their locations), provide the
    % mean, std, minimum, median and maximum
    fprintf(1, 'For all joint pairs:\n');
    L2Flat = reshape(L2(allValidJoints, :), 1, []);
    fprintf(1, 'Mean:\n');
    disp(mean(L2Flat));
    fprintf(1, 'Standard Deviation:\n');
    disp(std(L2Flat));
    fprintf(1, 'Median:\n');
    disp(median(L2Flat));
    fprintf(1, 'Minimum:\n');
    disp(min(L2Flat));
    fprintf(1, 'Maximum:\n');
    disp(max(L2Flat));

    % (3) For each mocap frame, compute the sum of L2 distances 
    totalErrors = sum(L2(allValidJoints, :), 2);
    frameNumbers = 1 : frames;
    % Plot the errors
    figure;
    plot(frameNumbers(allValidJoints), totalErrors);
    grid, title('Total Errors');
end