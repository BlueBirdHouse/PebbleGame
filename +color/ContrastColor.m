classdef ContrastColor < handle
    %ContrastColor ���ɶԱ�ɫ��һ��������
    %�ڶ�ĳ������ɫ��ʱ���Զ����ɶԱȶȽϸߵ���ɫ
    
    properties
        Counter = 0; %��������������¼�����˼�������ɫ��
        ColorRGB = [0 0 0]; %��ɫ�������RGB��ɫ��
        
        Hue;%ɫ��
        Saturation;%���Ͷ�
        Value;%����
    end
    
    properties(Constant = true)
        HueFactor = 1/24; %��ɫ�仯������������ʾÿ����һ����ɫ����ɫ�仯���١�
        SaturationFactor = 1/24; %����ָ������ɫѭ��һ���Ժ󣬱��Ͷȱ仯���١�
    end
    
    methods
        function obj = ContrastColor()
            obj.Counter = 0;
            obj.Hue = 0;
            obj.Saturation = 1;
            obj.Value = 1;
            %obj.Flash();
        end
        
        function Flash(obj)
            %����ɫװ�ò���һ������ɫ��
            HSV = [obj.Hue obj.Saturation obj.Value];
            obj.ColorRGB = hsv2rgb(HSV);
            if mod(obj.Counter,2) == 0
                %number is evenż��
                obj.Hue = obj.Hue + 0.5;
                obj.Hue = obj.DecimalNnumber(obj.Hue);
            else
                %number is odd����
                obj.Hue = obj.Hue + obj.HueFactor + 0.5;
                obj.Hue = obj.DecimalNnumber(obj.Hue);
            end
            
            if (mod(obj.Counter,(1/obj.HueFactor)) == 0)&&(obj.Counter ~= 0)
                %˵��ɫ��ѭ��һ����
                obj.Saturation = obj.Saturation - obj.SaturationFactor;
                if(obj.Saturation <= 0)
                    obj.Saturation = 1;
                end
            end
            obj.Counter = obj.Counter + 1;
        end
        
        function [Out] = DecimalNnumber(obj,In)
            %��ȡIn��С������
            Out = In;
            if(Out > 1)
                Out = Out - floor(Out);
            end
        end
    end
    
end

