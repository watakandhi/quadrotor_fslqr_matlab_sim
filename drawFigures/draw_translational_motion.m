%% Figure Position
set(gcf, 'Name', 'Position');

% Plot for x,y,z, u,v,w
numSubplot=3;
numData=6;
for i=1:numData
    indexSubplot=rem(i,numSubplot);
    if indexSubplot==1; figure
    elseif indexSubplot==0; indexSubplot=numSubplot;
    end
    subplot(numSubplot,1,indexSubplot)
    plot(T, X_data(i,:));
    xlabel(XLabels(1)); ylabel(YLabels(i));grid on;
    legend
end

%%  3D
figure
set(gcf, 'Name', '3D Position');
for n=1:length(T)
    plot3(X_data(1,1:n), X_data(2,1:n), X_data(3,1:n)); grid on;
    xlim([min(X_data(1,:)) max(X_data(1,:))]); ylim([min(X_data(2,:)) max(X_data(2,:))]); zlim([min(X_data(3,:)) max(X_data(3,:))]);
    xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
    drawnow;
end
