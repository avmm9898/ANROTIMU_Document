%% ���� IMU matlab���ճ���
clear;
clc;
close all;
format short;

%% Ĭ������
DEFALUT_BAUD = 115200;
PORT = 'COM4';

%% ����ѡ��
if length(serialportlist) >=1 %���ֶ������
    fprintf("���ô���:%s\n", serialportlist);
    fprintf("��ѡ�񴮿ڣ�����PORT����\n");
end

if length(serialportlist) == 1 %ֻ��һ������
    PORT = serialportlist;
end

if isempty(serialportlist) == true %û�д���
    fprintf("�޿��ô���\n");
end

%% ��ʾ
fprintf('��ʹ��matlab 2020b �����ϰ汾!!!\n');
fprintf('���� clear s  ���� CTRL+C ������ֹ���ڴ���\n');
x = input("���س�����...\n");

%% �򿪴���
s = serialport(PORT, DEFALUT_BAUD); %��������
%configureCallback(s,"byte",100,@callbackFcn)  %�����¼��ص�����

while true
    if  s.NumBytesAvailable > 0
        data = read(s, s.NumBytesAvailable,"uint8"); %��ȡ����������
        [imu_data, new_data_rdy] = parse_fame(data); %������������
        if new_data_rdy == 1
            fprintf("���ٶ�:%.3f %.3f %.3f\n", imu_data.acc);
            fprintf("���ٶ�:%.3f %.3f %.3f\n", imu_data.gyr);
            fprintf("ŷ����: Roll:%.2f Pitch:%.2f Yaw:%.2f\n", imu_data.roll, imu_data.pitch, imu_data.yaw);
        end
    end
    
    pause(0.02);
end


% ����֡��������
function imu_data = parse_data(data)

len = length(data); %�����򳤶�

offset = 1;
while offset < len
    byte = data(offset);
    switch byte
        case 0x90 % ID��ǩ
            imu_data.id = data(offset+1);
            offset = offset + 2;
        case 0xA0 %���ٶ�
            tmp = typecast(uint8(data(offset+1:offset+6)), 'int16');
            imu_data.acc = double(tmp) / 1000;
            offset = offset + 7;
        case 0xB0 %���ٶ�
            tmp = typecast(uint8(data(offset+1:offset+6)), 'int16');
            imu_data.gyr = double(tmp) / 10;
            offset = offset + 7;
        case 0xC0 %�ش�
            tmp = typecast(uint8(data(offset+1:offset+6)), 'int16');
            imu_data.mag = double(tmp) / 10;
            offset = offset + 7;
        case 0xD0 %ŷ����
            tmp = typecast(uint8(data(offset+1:offset+6)), 'int16');
            imu_data.pitch = double(tmp(1)) / 100;
            imu_data.roll = double(tmp(2)) / 100;
            imu_data.yaw = double(tmp(3)) / 10;
            offset = offset + 7;
        case 0xF0 % ��ѹ
            offset = offset + 5;
        case 0x91 % 0x91���ݰ�
            imu_data.id = data(offset+1);
            imu_data.acc =double(typecast(uint8(data(offset+12:offset+23)), 'single'));
            imu_data.gyr =double(typecast(uint8(data(offset+24:offset+35)), 'single'));
            imu_data.mag =double(typecast(uint8(data(offset+36:offset+47)), 'single'));
            imu_data.roll = double(typecast(uint8(data(offset+48:offset+51)), 'single'));
            imu_data.pitch = double(typecast(uint8(data(offset+52:offset+55)), 'single'));
            imu_data.yaw = double(typecast(uint8(data(offset+56:offset+59)), 'single'));
            imu_data.quat = double(typecast(uint8(data(offset+60:offset+75)), 'single'));
            offset = offset + 76;
        otherwise
            % offset = offset + 1;
    end
end

end



% ���һ֡����У��CRC
function [imu_data, new_data_rdy] = parse_fame(data)
imu_data = 0;
new_data_rdy = 0; %���ݽ��ܳɹ���׼���ɹ�����1֡:new_data_rdy=1, else: new_data_rdy=0

persistent current_state; %״̬��
if isempty(current_state)
    current_state=0;
end

persistent frame_len;   % ֡�������򳤶�
persistent frame_dat;  %һ֡��������
persistent frame_dat_cnt; %֡�������������

len = length(data);
if len > 0
    %data = read(src,src.NumBytesAvailable,"uint8");
    len = length(data);
    
    for i = 1:len
        byte = data(i);
        switch(current_state)
            case 0 %֡ͷ 0x5A
                if(byte == 0x5A)
                    frame_dat_cnt = 1;
                    current_state = 1;
                end
            case 1 %֡ͷ0xA5
                if(byte == 0xA5)
                    current_state = 2;
                end
            case 2 %���ȵ��ֽ�
                frame_len = byte;
                current_state = 3;
            case 3 %���ȸ��ֽ�
                frame_len = frame_len + byte*256;  % �����ֶ�
                current_state = 4;
            case 4 % CRC�ֶε�
                current_state = 5;
            case 5 % CRC�ֶθ�
                current_state = 6;
            case 6 % ֡�����ݶ�
                if(frame_dat_cnt >= frame_len+6)
                    crc1 = frame_dat(5) + frame_dat(6)*256;
                    
                    % ȥ��CRCУ���ֶ�
                    crc_text = frame_dat;
                    crc_text(5:6) = [];
                    
                    %����CRC У��ɹ�����ý������ݺ���
                    crc2 = crc16(double(crc_text));
                    if crc1 == crc2
                        imu_data = parse_data(frame_dat(7:end));
                        new_data_rdy = 1;
                    end
                    current_state = 0;
                end
        end
        frame_dat(frame_dat_cnt) = byte;
        frame_dat_cnt = frame_dat_cnt+1;
    end
end

end


% data = "5A A5 4C 00 6C 51 91 00 A0 3B 01 A8 02 97 BD BB 04 00 9C A0 65 3E A2 26 45 3F 5C E7 30 3F E2 D4 5A C2 E5 9D A0 C1 EB 23 EE C2 78 77 99 41 AB AA D1 C1 AB 2A 0A C2 8D E1 42 42 8F 1D A8 C1 1E 0C 36 C2 E6 E5 5A 3F C1 94 9E 3E B8 C0 9E BE BE DF 8D BE";
% data = sscanf(data,'%2x');
% parse_fame(data);




