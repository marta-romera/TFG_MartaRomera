function representar3(maxauc,ng,tipusmodel,k)
for k=1:15
    x{k}=ng{k};
     xticks([1 2 3 4 5])
     xticklabels({'16', '32', '64', '128', '256'})
    if strcmp(tipusmodel{k}, 'SVM')
        subplot(3,1,1);
        y{k}=maxauc{k};   
        ln=plot(x{k},y{k});
        grid on
        grid minor
        xlabel('Nivells de gris');
        ylabel('Max AUC');
        title('SVM - RELIEFF');  
        hold on
        axis([1 5 0.4 1])
        ln.LineWidth = 2;
        ln.Color = [0 1 1];
        ln.Marker = 'o';
        ln.MarkerEdgeColor = 'b';
    elseif strcmp(tipusmodel{k}, 'KNN')
        subplot(3,1,2);
        yy{k}=maxauc{k};
        ln= plot(x{k},yy{k});
        grid on
        grid minor
        xlabel('Nivells de gris');
        ylabel('Max AUC');
        title('KNN- RELIEFF');
        hold on
        axis([1 5 0.4 1])
        ln.LineWidth = 2;
        ln.Color = [0 0.5 0.5];
        ln.Marker = 'o';
        ln.MarkerEdgeColor = 'b';
    elseif strcmp(tipusmodel{k},'Decision Trees')
        subplot(3,1,3);
        yyy{k}=maxauc{k};
        ln= plot(x{k},yyy{k},'-');
        grid on
        grid minor
        xlabel('Nivells de gris');
        ylabel('Max AUC');
        title('DT - RELIEFF');
        hold on
        axis([1 5 0.4 1])
        ln.LineWidth = 2;
        ln.Color = [0 0.5 0.5];
        ln.Marker = 'o';
        ln.MarkerEdgeColor = 'b';
    end
end
end

