function representar(gris,vect,max,car,n)
    if gris{n}==1
        subplot(3,2,1);
        plot(vect{n})
        grid on
        grid minor
        legend('SVM','KNN','DT');
        t=text(car{n},max{n},'\leftarrow');
        t.FontSize = 14;
        xlabel('Number of features');
        ylabel('Vector AUC');
        title('AUC per NG1');
        hold on
        axis([0.3 130 0 1])
    elseif gris{n}==2
        subplot(3,2,2);
        plot(vect{n})
        grid on
        grid minor
        legend('SVM','KNN','DT');
        t=text(car{n},max{n},'\leftarrow');
        t.FontSize = 14;
        xlabel('Number of features');
        ylabel('Vector AUC');
        title('AUC per NG2');
        hold on 
        axis([0.3 130 0 1])
    elseif gris{n}==3
        subplot(3,2,3);
        plot(vect{n})
        grid on
        grid minor
        legend('SVM','KNN','DT');
        t=text(car{n},max{n},'\leftarrow');
        t.FontSize = 14;
        xlabel('Number of features');
        ylabel('Vector AUC');
        title('AUC per NG3');
        hold on
        axis([0.3 130 0 1])
    elseif gris{n}==4
        subplot(3,2,4);
        plot(vect{n})
        grid on
        grid minor
        legend('SVM','KNN','DT');
        t=text(car{n},max{n},'\leftarrow');
        t.FontSize = 14;
        xlabel('Number of features');
        ylabel('Vector AUC');
        title('AUC per NG4');
        hold on
        axis([0.3 130 0 1])
    elseif gris{n}==5
        subplot(3,2,5);
        plot(vect{n})
        grid on
        grid minor
        legend('SVM','KNN','DT');
        t=text(car{n},max{n},'\leftarrow');
        t.FontSize = 14;
        xlabel('Number of features');
        ylabel('Vector AUC');
        title('AUC per NG5');
        hold on
        axis([0.3 130 0 1])
    end
end