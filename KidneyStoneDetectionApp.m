classdef KidneyStoneDetectionApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        UploadButton            matlab.ui.control.Button
        OriginalImageAxes       matlab.ui.control.UIAxes
        ProcessedImageAxes      matlab.ui.control.UIAxes
        ResultLabel             matlab.ui.control.Label
    end
    
    methods (Access = private)

        % Callback function for the Upload Button
        function uploadImage(app, event)
            % Select image file
            [file, path] = uigetfile({'*.png;*.jpg;*.jpeg', 'Images (*.png, *.jpg)'});
            if isequal(file, 0)
                app.ResultLabel.Text = 'No file selected.';
                return;
            end
            imagePath = fullfile(path, file);
            originalImage = imread(imagePath);

            % Display the original image
            imshow(originalImage, 'Parent', app.OriginalImageAxes);
            title(app.OriginalImageAxes, 'Original Image');

            % Process the image
            grayImage = rgb2gray(originalImage); % Convert to grayscale
            filteredImage = medfilt2(grayImage); % Apply median filtering
            binaryImage = imbinarize(filteredImage, graythresh(filteredImage)); % Thresholding
            binaryImage = imfill(binaryImage, 'holes'); % Fill holes
            binaryImage = bwareaopen(binaryImage, 50); % Remove small artifacts

            % Display the processed image
            imshow(binaryImage, 'Parent', app.ProcessedImageAxes);
            title(app.ProcessedImageAxes, 'Processed Image');

            % Analyze the image for kidney stones
            props = regionprops(binaryImage, grayImage, {'Area', 'Centroid', 'MeanIntensity'});

            % Define detection criteria
            stoneDetected = false;
            hold(app.ProcessedImageAxes, 'on');
            for i = 1:length(props)
                if props(i).Area > 50 && props(i).MeanIntensity > 150 % Example thresholds
                    stoneDetected = true;
                    % Mark detected region
                    plot(app.ProcessedImageAxes, props(i).Centroid(1), props(i).Centroid(2), 'r*');
                end
            end
            hold(app.ProcessedImageAxes, 'off');

            % Update result label
            if stoneDetected
                app.ResultLabel.Text = 'Kidney stone detected!';
            else
                app.ResultLabel.Text = 'No kidney stones detected.';
            end
        end
    end

    % App initialization and construction
    methods (Access = public)

        % Construct app
        function app = KidneyStoneDetectionApp

            % Create and configure components
            createComponents(app)
        end
    end

    % Component creation
    methods (Access = private)

        % Create UI components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure('Position', [100 100 800 600]);

            % Create UploadButton
            app.UploadButton = uibutton(app.UIFigure, 'push', ...
                'Text', 'Upload Image', ...
                'Position', [50 500 100 30], ...
                'ButtonPushedFcn', @(btn, event) uploadImage(app));

            % Create OriginalImageAxes
            app.OriginalImageAxes = uiaxes(app.UIFigure, ...
                'Position', [200 300 250 250]);
            title(app.OriginalImageAxes, 'Original Image');

            % Create ProcessedImageAxes
            app.ProcessedImageAxes = uiaxes(app.UIFigure, ...
                'Position', [500 300 250 250]);
            title(app.ProcessedImageAxes, 'Processed Image');

            % Create ResultLabel
            app.ResultLabel = uilabel(app.UIFigure, ...
                'Text', 'Result will be displayed here.', ...
                'Position', [200 100 400 30], ...
                'FontSize', 14, ...
                'HorizontalAlignment', 'center');
        end
    end
end
