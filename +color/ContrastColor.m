classdef ContrastColor < handle
    %ContrastColor 生成对比色和一个计数器
    %在对某对象着色的时候，自动生成对比度较高的颜色
    
    properties
        Counter = 0; %计数器，用来记录生成了几次新颜色。
        ColorRGB = [0 0 0]; %着色器输出的RGB颜色。
        
        Hue;%色调
        Saturation;%饱和度
        Value;%明度
    end
    
    properties(Constant = true)
        HueFactor = 1/24; %颜色变化参数，用来表示每产生一种颜色，颜色变化多少。
        SaturationFactor = 1/24; %用来指定当颜色循环一周以后，饱和度变化多少。
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
            %让颜色装置产生一个新颜色。
            HSV = [obj.Hue obj.Saturation obj.Value];
            obj.ColorRGB = hsv2rgb(HSV);
            if mod(obj.Counter,2) == 0
                %number is even偶数
                obj.Hue = obj.Hue + 0.5;
                obj.Hue = obj.DecimalNnumber(obj.Hue);
            else
                %number is odd奇数
                obj.Hue = obj.Hue + obj.HueFactor + 0.5;
                obj.Hue = obj.DecimalNnumber(obj.Hue);
            end
            
            if (mod(obj.Counter,(1/obj.HueFactor)) == 0)&&(obj.Counter ~= 0)
                %说明色调循环一周了
                obj.Saturation = obj.Saturation - obj.SaturationFactor;
                if(obj.Saturation <= 0)
                    obj.Saturation = 1;
                end
            end
            obj.Counter = obj.Counter + 1;
        end
        
        function [Out] = DecimalNnumber(obj,In)
            %获取In的小数部分
            Out = In;
            if(Out > 1)
                Out = Out - floor(Out);
            end
        end
    end
    
end

