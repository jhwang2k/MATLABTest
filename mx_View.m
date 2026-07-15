function out = mx_View(strLocData), out = [];
%!!!!!!!!!!!@@@@@@@@@@@@@@@@@^^^^^^^^^^^^^^^^^^^^^^^^^^^^
% Add 15July2026A
% Add 15July2026B


addpath('FARAD');

po_DI = on_DI(); % data
po_DC = on_DC(); % view
po_DL = on_DL(); % control logic

po_CheckTag = @(hFig,x)(strcmp(x,...
    ancestor(hFig.CurrentObject,{'axes','uitable'},'toplevel').Tag )==1);
% aa = getappdata(gcf, "AddX");
runmain = @(strLocData_)uu_pipe({
    @(~)deal(po_DI(),po_DC(strLocData_),po_DL());
    @(DI,DC,DL)uu_void(@()({
        DI.seta('HOW_WIDE',400*1);
        DI.seta('HOW_MANY_IONS',0);
        DI.seta('set_HOW_WIDE',@(n)DI.seta('HOW_WIDE',n));
        DI.seta('set_HOW_MANY_IONS',@(n)DI.seta('ni',n));
        DI.seta('get_Peaks',@()DC.Peaks);
        DI.seta('AddX',@()uu_when({
            po_CheckTag(DI.hFig,'hChrom'), ...
                @()DL.po_AddSCaliper(DC,DI.geta,DI.seta,DI.hFig,DI.hSpec,DI.hChrom);
            po_CheckTag(DI.hFig,'hSpec'), ...
                @()DL.po_AddCIons(DC,DI.geta,DI.seta,DI.hFig,DI.hSpec,DI.hChrom);
            po_CheckTag(DI.hFig,'PeakTable'), ...
                @()DL.po_RowName(DI.geta,DI.hFig,DI.hTable,DC.nf,DI.geta('m'),1);
            }));
        DI.seta('NormX',@()DL.po_normhChrom(DI.hChrom,'flip'));

        % ConfigParams()
        set(DI.hFig,'Name',DC.strLocData);
        DI.seta('m',DC.m(:));
        DI.seta('ni',DI.geta('HOW_MANY_IONS'));
        DI.seta('DEFAULT_NORM_GCA','auto');
        DI.seta('RowX',zeros(DC.nf,1));
        set(DI.hTable,'Data',uu_when({~isempty(DC), @()DC.table_data;}));
        set(DI.hTable,'RowName',string(1:DC.nf));
        set(DI.hTable,'CellSelectionCallback',@(~,ed)uu_when({
            ~isempty(ed.Indices), @(){DI.seta('m',ed.Indices(:,1)),...
                DL.po_CS(DC,DI.prnInfo,DI.hChrom,DI.hSpec,DL.po_X(DC,DI.geta,DI.seta))};
            }));
        set(datacursormode(DI.hFig),'Enable','on','UpdateFcn',...
            @(~,eo)DL.po_Datacursor(eo,DC,DI.geta,DI.seta,DI.prnInfo,DI.hFig,DI.hChrom,DI.hSpec));
        }));
    });
runmain(strLocData);

end

function po_DL = on_DL()

po_Update_IonsLabelOfText = @(hSpec,ptext)uu_void(@(){
    % rotate all first
    set(ptext,'Clipping','on','FontSize',11,'Rotation',90,'color','w',...
        'Tag','IonsText');
    set(ptext,'Visible','on');
    uu_pipe({
        @(~)vertcat(ptext.Extent);
        @(pExtent)find(abs(diff(pExtent(:,1)))<pExtent(1,3))+1;
        @(ff_remove)set(ptext(ff_remove),'Visible','off');
        });
    set(ptext(1),'Rotation',0);
    % adjust YLim
    set(hSpec,'YGrid','on',...
        'YLim',[hSpec.YLim(1),ptext(1).Extent*[0;1;0;1]]);
    % flat the ions over the top
    set(ptext(vertcat(ptext.Extent)*[0;1;0;1]>ptext(1).Extent(2)),...
        'Rotation',0);
    % hide the overlapped ions
    uu_pipe({
        @(~)vertcat(ptext.Extent);
        @(pextent)[pextent(:,1:2),pextent(:,1:2)+pextent(:,3:4)];
        % closing peaks
        @(ppos)(...
            ppos(2:end,1)<cummax(ppos(1:end-1,3)) & ...
            ppos(2:end,2)<cummax(ppos(1:end-1,4)) & ...
            ppos(2:end,3)>cummin(ppos(1:end-1,1)) & ...
            ppos(2:end,4)>cummin(ppos(1:end-1,2)));
        @(ff_remove)set(ptext(find(ff_remove)+1),'Visible','off');
        });
    }); 

po_STopN = @(xx)mc_Base.fo_STopN(xx,500);

po_Update_IonsLabelOfSpectrum = @(DC,hSpec,m1)uu_pipe({
    @(~)findall(hSpec,'Tag','IonsText');    
    @(ptext)arrayfun(@(i)[' ',set(i,'String','')],ptext);
    @(~)po_STopN(DC.Peaks.SS(m1,:)');
    @(imz)text(hSpec,DC.i2mz(imz),double(DC.Peaks.SS(m1,imz))',...
        arrayfun(@(i)sprintf(" < %.2f ",DC.i2mz(i)),imz));
    @(ptext)po_Update_IonsLabelOfText(hSpec,ptext);
    });

po_plot_C = @(DC,hChrom,mm,m1,wd,ni,ia_mm_c2C,ib_mm_c2C)uu_pipe({
    @(~)deal(...
        uu_pipe({
            @(~)@(i)cell2mat(arrayfun(@(j)[...
                    nan(DC.Peaks.OA(i,j)-ia_mm_c2C(j)+1,1);...
                    double(DC.Peaks(i,:).CC{j}(:));...
                    nan(ib_mm_c2C(j)-DC.Peaks.OA(i,j)-DC.Peaks.WD(i,j),1)],...
                (1:DC.nSamples)','un',0));
            @(get_cci_)cell2mat(arrayfun(@(mmi)get_cci_(mmi),mm(:)','un',0));
            }),...
        uu_pipe({
            @(~)@(v)[v(1);v(find(v(2:end)~=v(1))+1)];
            @(rem1from2)[rem1from2(...
                [double(DC.Peaks.IQMZ(mm));mc_Base.fo_STopN(DC.Peaks.SS(m1,:)',ni)]);
                DC.mz2i(eval(['[',hChrom.Legend.Title.String,']']))'];
            }),...
        @(v)uu_pipe({ 
            @(~)string(v); 
            @(v)[v{:}]}) ...
        );
    @(cc,Ions,uu_strx)uu_void(@(){
        cla(hChrom);
        % plot raw X
        set(plot(hChrom,...
                max(DC.oX.fx_get_Chrom(DC.fxD_ncTiles,ia_mm_c2C,ib_mm_c2C,Ions),0)),...
            {'DisplayName'},...
            arrayfun(@(i)num2str(i,'%.2f'),DC.i2mz(Ions(:)'),'un',0));
        % plot cc
        set(plot(hChrom,cc,...
                'LineWidth',1,'Marker','o','LineStyle','-','MarkerSize',2),...
            {'Tag'}, arrayfun(@(i)uu_strx({'Id: ',i}),mm(:),'un',0),...
            {'DisplayName'}, arrayfun(@(i)...
                sprintf('%.2f',DC.i2mz(DC.Peaks.IQMZ(i))),mm(:),'un',0)...
            );
        set(hChrom,'XLim',[0,1]*double(wd*DC.nSamples));
        set(hChrom,'YLim',[min(0,min(cc(:))),max(cc(:))]*1.05);
        % XTick/XTickLabel
        set(hChrom.XRuler,'MinorTickValues',(1:DC.nSamples-1)*wd);
        set(hChrom,'XTick',...
            unique(reshape(...
            (0:DC.nSamples-1)*wd+1+DC.ic_c2C(...
            all((DC.ic_c2C-ia_mm_c2C)>=0,2) & ...
            all((ib_mm_c2C-DC.ic_c2C)>=0,2) ...
            ,:)-ia_mm_c2C,[],1)));
        set(hChrom,'XTickLabel',repmat({''},1,length(hChrom.XTick)));
        setfield(hChrom,'XTickLabel',...
            {uu_pipe({@(~)ismember(sort(reshape((0:DC.nSamples-1)*wd+1+DC.ic_c2C(m1,:)-ia_mm_c2C,[],1)),hChrom.XTick); ...
                @(~,yy)yy})},...
            arrayfun(@(i)uu_strx({i,'^{',DC.i2rt(DC.ic_c2C(m1,i)),'*',...
                DC.Peaks.FlagRule(m1,i),'}_{',DC.ic_c2C(m1,i),'+',...
                DC.Peaks.APEX_RTMAP(m1,i)-DC.Peaks.APEX(m1,i),'}'}),...
                1:DC.nSamples,'un',0));
        });
    });

po_plot_S = @(DC,hSpec,m1)uu_pipe({
    @(~)DC.Peaks(m1,:).SS';
    @(Si)Si(1:min(end,100+...
        find(max(abs(Si),[],2)>max(abs(Si(:)))/1000,1,'last')),:);
    @(Si)uu_void(@(){
        cla(hSpec);
        set(hSpec,'YLimMode','auto');
        plot(hSpec,DC.i2mz(1:length(Si)),Si,'k');
        po_Update_IonsLabelOfSpectrum(DC,hSpec,m1);
        });
    });

po_normhChrom = @(hChrom,myYLimMode)uu_when({
    strcmpi(myYLimMode,get(hChrom,'YLimMode'))==1, @()hChrom;
    strcmpi('auto',get(hChrom,'YLimMode'))==1, @()uu_void(@(){
        arrayfun(@(h)set(h,...
            'UserData',[min(h.YData,[],'omitnan'),max(h.YData,[],'omitnan')],...
            'YData',(h.YData - min(h.YData,[],'omitnan'))/max(eps*100,max(h.YData,[],'omitnan'))),...
            hChrom.Children,'Un',0);
        set(hChrom,'YLim',[0,1.05]);
        },hChrom);
    true, @()uu_void(@(){
        arrayfun(@(h)uu_when({
                    isempty(h.UserData), @()0;
                    true,@()set(h,'YData',h.YData*h.UserData(2) + h.UserData(1));
                }),...
            hChrom.Children,'Un',0);
        set(hChrom,'YLimMode','auto');
        },hChrom);
    });

po_X = @(DC,hgeta,hseta)uu_pipe({ 
    @(~){
    % m for selected in table; mm is m plus left column selection
    'DEFAULT_NORM_GCA', hgeta('DEFAULT_NORM_GCA');
    'ni', hgeta('ni');
    'm', hgeta('m');
    'mm', hseta('mm',unique([find(hgeta('RowX'));hgeta('m')]));
    'ia_mm_c2C', hseta('ia_mm_c2C',...
        max(1,min(DC.ia_c2C(hgeta('mm'),:),[],1)-hgeta('HOW_WIDE')));
    'ib_mm_c2C9', hseta('ib_mm_c2C9',...
        max(DC.ib_c2C(hgeta('mm'),:),[],1)+hgeta('HOW_WIDE'));
    'wd', hseta('wd',1+max(max(hgeta('ib_mm_c2C9')-hgeta('ia_mm_c2C'))));
    'ib_mm_c2C', hseta('ib_mm_c2C',hgeta('ia_mm_c2C')+hgeta('wd')-1);
    }; 
    @(xx)cell2struct(xx(:,2), xx(:,1)); 
    });

po_C = @(DC,hChrom,Y)uu_void(@(){
    po_plot_C(DC,hChrom,Y.mm,Y.m(1),Y.wd,Y.ni,Y.ia_mm_c2C,Y.ib_mm_c2C);
    set(hChrom,'YLimMode','auto');
    % po_normhChrom(hChrom,'manual');
    });
po_S = @(DC,hSpec,Y)po_plot_S(DC,hSpec,Y.m(1));
po_CS = @(DC,p__Disp,hChrom,hSpec,Y)uu_void(@(){
    po_C(DC,hChrom,Y);
    po_S(DC,hSpec,Y);
    p__Disp(Y,{''})});

po_DataCursorPos = @(hFig,hgca)uu_pipe({
    @(~)getCursorInfo(datacursormode(hFig));
    @(dcur0)dcur0(arrayfun(@(i)i.Target.Parent==hgca,dcur0));
    @(dcur)[cat(1,dcur.DataIndex),cat(1,dcur.Position)];
    @(iiPos)sortrows(iiPos,3,'descend');
    @(iiPos_sorted)iiPos_sorted(:,1);
    });

po_CaliperSpec = @(DC,Y,ii)uu_pipe({
    @(~)cell2mat(arrayfun(@(i)DC.oX.fx_get_Spectrum(DC.fxD_nsTiles,ceil(i/Y.wd),...
        (i-(ceil(i/Y.wd)-1)*Y.wd+Y.ia_mm_c2C(ceil(i/Y.wd))-1)),...
        ii(1:min(3,end))','un',0));
    @(S)(S(:,1)-fillmissing(mean(S(:,2:min(end,3)),2),'constant',0));
    @(S)S/max(S);
    @(S)S(1:min(end,100+find(S>1/1000,1,'last')),:);
    });

po_AddSCaliper = @(DC,hgeta,hseta,hFig,hSpec,hChrom)uu_pipe({
    @(~)deal(po_X(DC,hgeta,hseta),...
        po_CaliperSpec(DC,po_X(DC,hgeta,hseta),po_DataCursorPos(hFig,hChrom)));
    @(Y,Si)uu_void(@(){
        set(hSpec,'YLimMode','auto');
        plot(hSpec,DC.i2mz(1:length(Si)),-Si,'k');
        po_Update_IonsLabelOfSpectrum(DC,hSpec,Y.m(1));
        });
    });

po_AddCIons = @(DC,hgeta,hseta,hFig,hSpec,hChrom)uu_pipe({
    @(~)deal(po_X(DC,hgeta,hseta), po_DataCursorPos(hFig,hSpec));
    @(Y,ii)set(plot(hChrom,max(0,DC.oX.fx_get_Chrom(...
        DC.fxD_ncTiles,Y.ia_mm_c2C,Y.ib_mm_c2C,ii))),...
        {'DisplayName'},arrayfun(@(i)num2str(DC.i2mz(i),'%.2f'),ii,'un',0));
    });

po_Datacursor = @(eo,DC,hgeta,hseta,p__Disp,hFig,hChrom,hSpec)uu_pipe({
    @(~)deal(...
        @(Y,pos,o_o)uu_pipe({
            @(~)pos(1);
            @(i)(i-(ceil(i/Y.wd)-1)*Y.wd+Y.ia_mm_c2C(ceil(i/Y.wd))-1);
            @(idx)uu_void(...
                @()p__Disp(Y,{' %s  i: %.0f  X: %.0f  rt: %.2f  Y: %g',...
                    o_o.Tag, pos(1), idx, DC.i2rt(idx), pos(2)}),...
                {num2str(idx,'%.0f')});          
            }),...
        @(Y,pos,dataindex)uu_void(...
            @()p__Disp(Y,{' i: %.0f  mz: %.2f Y: %g',dataindex(1),pos(1),pos(2)}),...
            {num2str(pos(1),'%.2f')} ...
            ));
    @(hdcm_Chrom,hdcm_Spec)uu_when({
        ancestor(hFig.CurrentObject,'axes')==hChrom, ...
            @()hdcm_Chrom(po_X(DC,hgeta,hseta),eo.Position,eo.Target);
        ancestor(hFig.CurrentObject,'axes')==hSpec, ...
            @()hdcm_Spec(po_X(DC,hgeta,hseta),eo.Position,eo.DataIndex);
        });
    });

po_RowName = @(hgeta,hFig,hTable_,DC_nf,ii,x){
    uu_when({isempty(ii),@()setfield(hFig,'UserData','RowX',{':'},x);});
    uu_when({~isempty(ii),@()setfield(hFig,'UserData','RowX',{ii},x);});
    setfield(hTable_,'RowName',string(1:DC_nf));
    setfield(hTable_,'RowName',{hgeta('RowX')==1},{'>'});
    };

po_DL = @()struct(...
    'po_X',po_X,...
    'po_CS',po_CS,...
    'po_CaliperSpec',po_CaliperSpec,...
    'po_AddSCaliper',po_AddSCaliper,...
    'po_AddCIons',po_AddCIons,...
    'po_Datacursor',po_Datacursor,...
    'po_normhChrom',po_normhChrom,...
    'po_RowName',po_RowName...
    );
end
function po_DC = on_DC()

po_DC = @(strLocData)uu_pipe({
    @(~)uu_pipe({
        @(~)mf_UD();
        @(~,hf)hf.Init_load(strLocData,-1);
        });
    @(DC)setfield(DC,'strLocData',strLocData);
    @(DC)setfield(DC,'iSample',1);
    @(DC)setfield(DC,'m',1);
    @(DC)setfield(DC,'oX',uu_pipe({
        @(~)arrayfun(@(x)fullfile(strLocData,x.name), ...
        dir(fullfile(strLocData,'*.SMP')),'UniformOutput',false);
        @(strXNames)mC_Data().Init(strXNames,DC.fxD_MBC0C1C2,...
        DC.fxD_ReferenceMassCalibrationForTofResampling);
        }));
    @(DC)setfield(DC,'Peaks',uu_pipe({ 
        @(~)fullfile(strLocData,'DPSpace','Peaks.mat');
        @(strLocFD)load(strLocFD).Peaks; 
        }));
    @(DC)setfield(DC,'Peaks',uu_when({
        isa(DC.Peaks.OA,'cell'), @()Peaks4GCxGC(DC.Peaks); 
        true, @()DC.Peaks; 
        }));
    @(DC)setfield(DC,'nSamples',size(DC.Peaks.APEX,2));
    @(DC)setfield(DC,'ns',size(DC.Peaks.SS,2));
    @(DC)setfield(DC,'nf',height(DC.Peaks));
    @(DC)setfield(DC,'Peaks','APEX_RTMAP',uu_when({ 
        DC.nSamples==1,@()DC.Peaks.APEX; 
        true,@()DC.Peaks.APEX_RTMAP;
        }));
    @(DC)setfield(DC,'Peaks','FlagRule',uu_when({ 
        DC.nSamples==1,@()ones(DC.nf,1); 
        true,@()DC.Peaks.FlagRule; 
        }));
    @(DC)setfield(DC,'Peaks','WD',cellfun(@length,DC.Peaks.CC));
    @(DC)setfield(DC,'Peaks','CC',{cellfun(@isempty,DC.Peaks.CC)>0},...
        {single(0)});
    @(DC)setfield(DC,'ib_c2cc',cumsum(DC.Peaks.WD,2));
    @(DC)setfield(DC,'ia_c2cc',[ones(1,size(DC.ib_c2cc,2));DC.ib_c2cc(1:end-1,:)]);
    @(DC)setfield(DC,'ia_c2C',DC.Peaks.OA + 1);
    @(DC)setfield(DC,'ib_c2C', DC.Peaks.WD + DC.ia_c2C-1);
    @(DC)setfield(DC,'ic_c2C', max(min(double(DC.Peaks.APEX),DC.ib_c2C-1),DC.ia_c2C+1));
    @(DC)setfield(DC,'Smax', max(DC.Peaks.SS,[],2));
    @(DC)setfield(DC,'i2rt', @(i)uu_pipe({
        @(~)double(i);
        @(i)round(10*(i+DC.fxD_delayRT(1))/DC.fxD_SpectraPerSecond(1))*0.1;
        }));
    @(DC)setfield(DC,'i2mz', @(i)uu_pipe({
        @(~)DC.fxD_MBC0C1C2(:,1);
        @(v)deal(double(i),v(1),v(2),v(3),v(4),v(5));
        @(i,M,B,c0,c1,c2)(c0+c1*(M*(i-1)+B)+c2*(M*(i-1)+B).^2)';
        }));
    @(DC)setfield(DC,'mz2i', @(mz)uu_pipe({
        @(~)DC.fxD_MBC0C1C2(:,1);
        @(v)deal(mz,v(1),v(2),v(3),v(4),v(5));
        @(mz,M,B,c0,c1,c2)round((((-c1+sqrt(c1^2-4*c2*(c0-mz)))/(2*c2))-B)/M+1);
        }));
    @(DC)setfield(DC,'table_data', [DC.ic_c2C(:,DC.iSample),...
        DC.i2rt(double(DC.ic_c2C(:,DC.iSample))),...
        round(max(DC.Peaks.SvN,[],2)), round(max(DC.Peaks.PQ,[],2)*10)]);
    });

end
function po_DI = on_DI()
po_DI = @()uu_pipe({
    @(~)struct();
    @(DI)setfield(DI,'po_hFig',...
    @()uu_when({
        isempty(findobj('Tag','FARADViewer')), @()uu_pipe({
            @(~)get(0,'ScreenSize');
            @(p)uifigure('pos',[102,p(4)-769,1024,699],...
                'Tag','FARADViewer','Vis','off','Hand','on',...
                'ToolBar','none','MenuBar','none','Color',[1,1,1]/3);
            });
        true, @()uu_pipe({
            @(~)get(gcf,'pos');
            @(hpos)uu_void(@()close(gcf),hpos);
            @(hpos)uifigure('pos',hpos,'Vis','on','Hand','on');
            });
        }));
    @(DI)setfield(DI,'po_Grid',...
        @(hFigt)uigridlayout(hFigt,'Padding',0,'RowSpacing',10,...
        'RowHeight',{'3x','2x',25},'ColumnWidth',{'fit','1x'})...
        );
    @(DI)setfield(DI,'po_SetRowColum', @(hX,a,b)...
        setfield(setfield(hX,'Layout','Row',a),'Layout','Column',b)...
        );
    @(DI)setfield(DI,'po_StatusText', @(gridxxt)uicontrol(DI.po_SetRowColum( ...
        uipanel(gridxxt,'BorderType','line'),3,2), ...
        'Style', 'text', 'Units', 'normalized', 'String', 'info', ...
        'Position', [0.02,0.05,0.93,0.8], 'HorizontalAlignment', 'left')...
        );   
    @(DI)setfield(DI,'po_hTable', @(gridxxt)DI.po_SetRowColum(uitable(gridxxt, 'Tag','PeakTable',...
        'FontSize',12,'ColumnWidth',{'fit','fit','fit','fit'},...
        'ColumnName', {'loc';'sec';'max';'pq'},...
        'ColumnFormat', {'numeric','bank','numeric','numeric'},...
        'ColumnEditable', [false,false,false,false]),[1,3],1)...
        );        
    @(DI)setfield(DI,'po_hChrom', @(gridxxt)DI.po_SetRowColum( ...
        uiaxes(gridxxt,'Tag','hChrom','NextPlot','add','XTickLabelRotation',0,...
        'GridAlpha',0.3,'MinorGridAlpha',1,'XGrid','on','XMinorGrid','on',...
        'YGrid','off','GridLineStyle','-','MinorGridLineStyle','-',...
        'XMinorTick','off','XTick',[],'GridColor',[1,1,1]/2,'TickLength',[0,0],...
        'Box','on','TickDir','out','Color',[1,1,1]/2,'XLimSpec','Tight'),1,2)...
        );
    @(DI)setfield(DI,'po_hSpec', @(gridxxt)DI.po_SetRowColum(uiaxes(gridxxt,'Tag','hSpec', ...
        'NextPlot','add','TickLength',[0,0],'Box','on','TickDir','out', ...
        'Color',[1,1,1]/2,'XLimSpec','Tight','XGrid','off','YGrid','off'),2,2)...
        );
    @(DI)setfield(DI,'po_flasha', ...
        @(e,w){setfield(e,'Peer','LineWidth',w);uu_void(@()pause(0.2));}...
        );
    @(DI)setfield(DI,'po_flashb', ...
        @(e)arrayfun(@(i){DI.po_flasha(e,3);DI.po_flasha(e,0.5);},1:3,'Un',0)...
        );
    @(DI)setfield(DI,'po_Legend', @(hChromt)legend(hChromt,...
        'box','off','Orientation','horizontal',...
        'NumColumns',6,'Location','southoutside','Tag','ChromLegend',...
        'ItemHitFcn',@(~,e)DI.po_flashb(e))...
        );
    @(DI)setfield(DI,'hFig',DI.po_hFig());
    @(DI)setfield(DI,'hgrid',DI.po_Grid(DI.hFig));
    @(DI)setfield(DI,'statusText',DI.po_StatusText(DI.hgrid));
    @(DI)setfield(DI,'prnInfo',...
        @(Y,a)set(DI.statusText,'String',"Peak: "+Y.m(1)+sprintf(a{:})));
    @(DI)setfield(DI,'hTable',DI.po_hTable(DI.hgrid));
    @(DI)setfield(DI,'hSpec',DI.po_hSpec(DI.hgrid));
    @(DI)setfield(DI,'hChrom',DI.po_hChrom(DI.hgrid));
    @(DI)setfield(DI,'geta',@(a)getappdata(DI.hFig, a));
    @(DI)setfield(DI,'seta',@(a,b)uu_void(@()setappdata(DI.hFig, a, b),b));
    @(DI)uu_void(@(){
        uu_void(@()enableLegacyExplorationModes(DI.hFig));
        DI.po_Legend(DI.hChrom);
        set(axtoolbar(DI.hChrom,'default'),'Vis','on');
        set(axtoolbar(DI.hSpec,'default'),'Vis','on');     
        uu_void(@()drawnow());
        set(DI.hFig,'Visible','on');
        },DI);
    });
end

%% Pure Programming Function Utilities ------------------------------------
function v = uu_when(xx), ii = find(cell2mat(xx(:,1)), 1, 'first');
if ~isempty(ii), v = xx{ii,2}(); else, v = []; end
end
function varargout = uu_void(f, varargin)
f(); 
if nargin>1
    [varargout{1:nargout}] = deal(varargin{:});
else
    varargout{1} = 1;
end
end
function varargout = uu_pipe(xx)

if nargin==0, return; end
if length(xx)==1, [varargout{1:nargout}] = xx{1}(); return; end  %#ok

n = nargin(xx{2});
varargout2 = cell(1,n);
[varargout2{1:n}] = xx{1}(); 
for i = 2:length(xx)-1
    n = nargin(xx{i+1});
    varargout1 = varargout2;
    varargout2 = cell(1,n);
    [varargout2{1:n}] = xx{i}(varargout1{:});
end
[varargout{1:nargout}] = xx{end}(varargout2{:});

end

%%

