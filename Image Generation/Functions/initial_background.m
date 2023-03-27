function initial_background(color_background, color_plate, outres, image_dpi)

set(gcf, 'Color', color_background)
%set(gcf,'PaperPositionMode','auto')
%set(gcf, 'Position', [0 0 5.72 5.72])
axis equal
set(gca,'visible','off')
set(gca,'Color', color_background)

set(gca,'xtick',[])
set(gca,'ytick',[])

%axis equal tight image
axis equal tight
%set(gcf,'PaperUnits','inches','PaperPosition',[0 0 5*(3.81 + 1/300) 5*(3.81 + 1/300)])
set(gcf,'PaperUnits','inches','PaperPosition',(outres/image_dpi).*[0 0 1 1])
set(gca,'Color', color_plate)
set(gcf, 'InvertHardCopy', 'off');

% Remove margins

ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

end