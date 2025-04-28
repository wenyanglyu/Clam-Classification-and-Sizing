function test_opt(trainedNet,imdsTest)
% Use the trained network to make predictions on the test data
YPred = classify(trainedNet, imdsTest);
% Get the actual labels of the test data
YTest = imdsTest.Labels;
% Calculate the accuracy
accuracy = mean(YPred == YTest);
% Display the accuracy
disp(['Test Accuracy: ', num2str(accuracy)]);

% Calculate and display the confusion matrix
confMat = confusionmat(YTest, YPred);
disp('Confusion Matrix:');
disp(confMat);

% Plot the confusion matrix
figure;
confusionchart(YTest, YPred);
title('Confusion Matrix');
end