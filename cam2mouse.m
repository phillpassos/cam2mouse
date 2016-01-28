%% Obter informa��es sobre a c�mera.

% Rode a linha abaixo, substituindo o segundo argumento por n�meros
% sequenciais (1, 2, etc) at� ele listar a c�mera desejada no console.
%camera = imaqhwinfo('winvideo', 1)

% Substitua aqui o segundo argumento pelo n�mero da c�mera encontrado
% acima, e o terceiro argumento pela string correspondente � resolu��o
% escolhida acima.
vidobj = videoinput('winvideo', 1, 'YUY2_160x120');

%resolucao da imagem da camera
res_img_x = 160;
res_img_y = 120;

%resolucao do monitor
scr_size = get(0,'screensize');
scr_x = scr_size(3);
scr_y = scr_size(4);

%utilizando o java
import java.awt.Robot;

triggerconfig(vidobj, 'manual');

% Comente/Descomente a linha abaixo se a c�mera n�o suportar RGB (isso far� com
% que o pr�prio Matlab se encarregue de converter a imagem para RGB).
set(vidobj, 'ReturnedColorspace', 'RGB');

% Iniciar a captura do v�deo.
start(vidobj);

% Variaveis contadoras de FPSs
lasttime = 0;
fpscounter = 0;

%loop principal (ainda nao tem parametros de finalizacao.)
while true
    % Obter o frame.
    img = getsnapshot(vidobj);
    
    % Converter para HSV e pegar o canal H. Este canal contem as
    % informa�oes de cores.
    
    img2 = rgb2hsv(img);
    img2 = img2(:,:,1);
    
    % Binarizar a imagem capturando o azul. (Azuis comecam em 0.6 aprox)
        img2 = img2 > 0.6;
    
    % Remover ru�do (uma eros�o, seguida de uma dilata��o � simples e foi
    % suficiente remover a maior parte do ru�do).
    img2 = imerode(img2, strel('diamond', 1));
    img2 = imdilate(img2, strel('diamond', 1));
    
    % Encontrar os grupos conexos, usando a 'regionprops', da toolbox de
    % processamento de imagens.
    grupos = regionprops(img2);
    
    % Encontrando o maior grupo conexo (o restante provavelmente �
    % ru�do e ser� descartado).
    if numel(grupos) > 0
        maior = 1;
        for i = 2:numel(grupos)
            if grupos(i).Area > grupos(maior).Area
                maior = i;
            end
        end
        %pegando a posicao central do grupo
        grp_pos = grupos(maior).Centroid;
        pos_rel_grp_x = grp_pos(1);
        pos_rel_grp_y = grp_pos(2);
        
        %criando as coordenadas relativas da imagem
        rel_x = (100 * pos_rel_grp_x) / res_img_x;
        rel_y = (100 * pos_rel_grp_y) / res_img_y;
        
        %invertendo posicao de x
        rel_x = 100 - rel_x;
        
        %criando o robot do java
        mouse = Robot;
        
        %movendo o mouse para a posicao relativa a imagem da camera
        
        pos_mouse_x = (scr_x * rel_x) / 100;
        pos_mouse_y = (scr_y * rel_y) / 100;
        
        %a proxima linha foi comentada para que o ponteiro mouse nao fique se movendo
        %pela tela durante o desenvlvimento. Descomente para utilizar o
        %sistema.
        
        %mouse.mouseMove(pos_mouse_x, pos_mouse_y);
        pause(0.00001);
    else
        maior = -1;
    end
    % Vamos exibir a imagem original.
    imshow(img);
    
    % Vamos plotar o rastro, por cima da imagem.
    hold on
    if maior ~= -1
        rectangle('Position', grupos(maior).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 3);
    end
    hold off
    drawnow;
    
    %Contador de FPSs
    timenow = clock;
    splitedtime = strsplit(num2str(timenow(6)), '.');
    temp = cell2mat(splitedtime(1));
    if lasttime == temp
        fpscounter = fpscounter + 1;
    else
        lasttime = temp;
        fpscounter
        fpscounter = 0;
    end
    %fim do contador de FPSs
    
end

%% Desconectar a c�mera.

stop(vidobj);