clc
pwd
clear
 % first load the ciphertexts and plaintext through this file..
load obtained_files_for_attacks/simple_fault/challenge.mat

%sbox() ----- max.: sbox(16, 63:64)
%      0 3:4;  1 7:8   2 11:12 3      4       5        6       7
sbox = [
    '0x63', '0x7C', '0x77', '0x7B', '0xF2', '0x6B', '0x6F', '0xC5', '0x30', '0x01', '0x67', '0x2B', '0xFE', '0xD7', '0xAB', '0x76';
    '0xCA', '0x82', '0xC9', '0x7D', '0xFA', '0x59', '0x47', '0xF0', '0xAD', '0xD4', '0xA2', '0xAF', '0x9C', '0xA4', '0x72', '0xC0';
    '0xB7', '0xFD', '0x93', '0x26', '0x36', '0x3F', '0xF7', '0xCC', '0x34', '0xA5', '0xE5', '0xF1', '0x71', '0xD8', '0x31', '0x15';
    '0x04', '0xC7', '0x23', '0xC3', '0x18', '0x96', '0x05', '0x9A', '0x07', '0x12', '0x80', '0xE2', '0xEB', '0x27', '0xB2', '0x75';
    '0x09', '0x83', '0x2C', '0x1A', '0x1B', '0x6E', '0x5A', '0xA0', '0x52', '0x3B', '0xD6', '0xB3', '0x29', '0xE3', '0x2F', '0x84';
    '0x53', '0xD1', '0x00', '0xED', '0x20', '0xFC', '0xB1', '0x5B', '0x6A', '0xCB', '0xBE', '0x39', '0x4A', '0x4C', '0x58', '0xCF';
    '0xD0', '0xEF', '0xAA', '0xFB', '0x43', '0x4D', '0x33', '0x85', '0x45', '0xF9', '0x02', '0x7F', '0x50', '0x3C', '0x9F', '0xA8';
    '0x51', '0xA3', '0x40', '0x8F', '0x92', '0x9D', '0x38', '0xF5', '0xBC', '0xB6', '0xDA', '0x21', '0x10', '0xFF', '0xF3', '0xD2';
    '0xCD', '0x0C', '0x13', '0xEC', '0x5F', '0x97', '0x44', '0x17', '0xC4', '0xA7', '0x7E', '0x3D', '0x64', '0x5D', '0x19', '0x73';
    '0x60', '0x81', '0x4F', '0xDC', '0x22', '0x2A', '0x90', '0x88', '0x46', '0xEE', '0xB8', '0x14', '0xDE', '0x5E', '0x0B', '0xDB';
    '0xE0', '0x32', '0x3A', '0x0A', '0x49', '0x06', '0x24', '0x5C', '0xC2', '0xD3', '0xAC', '0x62', '0x91', '0x95', '0xE4', '0x79';
    '0xE7', '0xC8', '0x37', '0x6D', '0x8D', '0xD5', '0x4E', '0xA9', '0x6C', '0x56', '0xF4', '0xEA', '0x65', '0x7A', '0xAE', '0x08';
    '0xBA', '0x78', '0x25', '0x2E', '0x1C', '0xA6', '0xB4', '0xC6', '0xE8', '0xDD', '0x74', '0x1F', '0x4B', '0xBD', '0x8B', '0x8A';
    '0x70', '0x3E', '0xB5', '0x66', '0x48', '0x03', '0xF6', '0x0E', '0x61', '0x35', '0x57', '0xB9', '0x86', '0xC1', '0x1D', '0x9E';
    '0xE1', '0xF8', '0x98', '0x11', '0x69', '0xD9', '0x8E', '0x94', '0x9B', '0x1E', '0x87', '0xE9', '0xCE', '0x55', '0x28', '0xDF';
    '0x8C', '0xA1', '0x89', '0x0D', '0xBF', '0xE6', '0x42', '0x68', '0x41', '0x99', '0x2D', '0x0F', '0xB0', '0x54', '0xBB', '0x16'
 ];

% What I've figured out so far for the simple fault attack: 
% all that shit I thought before were wrong :D 

% I know now that we have the ciphertext C' which is output of 9 AES rounds and by the round reduction fault it skips the last operations
% so I can just do a SB and SR for the C' as input and the test all possible RK_10 keys with one byte after another and XOR them together

function [SbOutput] = SB(state, sbox)
    for i = 1 : 16
        a = state(1, i); %we are taking only the first 16B from the aes blocks.. there are 9 more.. 
        a = dec2hex(a);
        
        if (a == 'A' || a == 'B' || a == 'C' || a == 'D' || a == 'E' || a == 'F' || a == '1' || a == '2' || a == '3' || a == '4'|| a == '5' || a == '6'|| a == '7' || a == '8' || a == '9')
            %disp('pozor')
            if a == '0'
                tmp1 = '0';
                tmp2 = '0';
            else
                tmp1 = a;
                tmp2 = '0';
            end
        else
            tmp1 = a(1);
            tmp2 = a(2);
        end %end of if (a == 'A' .....)
        tmp1 = hex2dec(tmp1);
        tmp2 = hex2dec(tmp2);
        for b = 0 : 15
            index = 3;
            for c = 0 : 15
                if (b == tmp1 && c == tmp2)
                    helperArray(i, 1:2) = sbox(b+1, index:(index+1));   %the actual going through sbox and taking out the right value y axis (b), x axis (c)
                    SbOutput(i) = hex2dec(helperArray(i, 1:2));         %converting back to dec, impossible to store strings together and be able to 
                                                                        %access them using indexes.. like: helperArray(i) and get 'FF' -- matlab.. xD
                end                                                     %even javascript can do that shit :D
                index += 4;   
            end
        end %end of for b = 0 : 15
    end %end of for i = 1 : 16
end %end of SB function

function [SrOutput] = SR(SbOutput)
    SbOutput = reshape(SbOutput, 4,4);
    SrOutput = reshape (SbOutput([1 6 11 16 5 10 15 4 9 14 3 8 13 2 7 12]), 4,4); %for left rotation
end %end of SR function

SbOutput = SB(aes_ct_fault ,sbox);
SrOutput = SR(SbOutput);


% guessed_key = zeros(1, 255);%declare an array for key guess
% for j = 1 : 255
%     guessed_key(j) = j; %fill it with num 1-255
% end
% guessed_key = dec2bin(guessed_key, 8);%converting to binary (8bits)

% create rcon for AddRoundKey opeartion; needed only rcon(1) - rcon(11) for 128 AES; rcon(1) - 0x8d not used.. start from rcon(2)
rcon = [
    '0x8d', '0x01', '0x02', '0x04', '0x08', '0x10', '0x20', '0x40', '0x80', '0x1b', '0x36'
];

% rcon = {
%     '0x8d', '0x01', '0x02', '0x04', '0x08', '0x10', '0x20', '0x40', '0x80', '0x1b', '0x36', '0x6c', '0xd8', '0xab', '0x4d', '0x9a'; 
%     '0x2f', '0x5e', '0xbc', '0x63', '0xc6', '0x97', '0x35', '0x6a', '0xd4', '0xb3', '0x7d', '0xfa', '0xef', '0xc5', '0x91', '0x39'; 
%     '0x72', '0xe4', '0xd3', '0xbd', '0x61', '0xc2', '0x9f', '0x25', '0x4a', '0x94', '0x33', '0x66', '0xcc', '0x83', '0x1d', '0x3a'; 
%     '0x74', '0xe8', '0xcb', '0x8d', '0x01', '0x02', '0x04', '0x08', '0x10', '0x20', '0x40', '0x80', '0x1b', '0x36', '0x6c', '0xd8'; 
%     '0xab', '0x4d', '0x9a', '0x2f', '0x5e', '0xbc', '0x63', '0xc6', '0x97', '0x35', '0x6a', '0xd4', '0xb3', '0x7d', '0xfa', '0xef'; 
%     '0xc5', '0x91', '0x39', '0x72', '0xe4', '0xd3', '0xbd', '0x61', '0xc2', '0x9f', '0x25', '0x4a', '0x94', '0x33', '0x66', '0xcc'; 
%     '0x83', '0x1d', '0x3a', '0x74', '0xe8', '0xcb', '0x8d', '0x01', '0x02', '0x04', '0x08', '0x10', '0x20', '0x40', '0x80', '0x1b'; 
%     '0x36', '0x6c', '0xd8', '0xab', '0x4d', '0x9a', '0x2f', '0x5e', '0xbc', '0x63', '0xc6', '0x97', '0x35', '0x6a', '0xd4', '0xb3'; 
%     '0x7d', '0xfa', '0xef', '0xc5', '0x91', '0x39', '0x72', '0xe4', '0xd3', '0xbd', '0x61', '0xc2', '0x9f', '0x25', '0x4a', '0x94'; 
%     '0x33', '0x66', '0xcc', '0x83', '0x1d', '0x3a', '0x74', '0xe8', '0xcb', '0x8d', '0x01', '0x02', '0x04', '0x08', '0x10', '0x20'; 
%     '0x40', '0x80', '0x1b', '0x36', '0x6c', '0xd8', '0xab', '0x4d', '0x9a', '0x2f', '0x5e', '0xbc', '0x63', '0xc6', '0x97', '0x35'; 
%     '0x6a', '0xd4', '0xb3', '0x7d', '0xfa', '0xef', '0xc5', '0x91', '0x39', '0x72', '0xe4', '0xd3', '0xbd', '0x61', '0xc2', '0x9f'; 
%     '0x25', '0x4a', '0x94', '0x33', '0x66', '0xcc', '0x83', '0x1d', '0x3a', '0x74', '0xe8', '0xcb', '0x8d', '0x01', '0x02', '0x04'; 
%     '0x08', '0x10', '0x20', '0x40', '0x80', '0x1b', '0x36', '0x6c', '0xd8', '0xab', '0x4d', '0x9a', '0x2f', '0x5e', '0xbc', '0x63'; 
%     '0xc6', '0x97', '0x35', '0x6a', '0xd4', '0xb3', '0x7d', '0xfa', '0xef', '0xc5', '0x91', '0x39', '0x72', '0xe4', '0xd3', '0xbd'; 
%     '0x61', '0xc2', '0x9f', '0x25', '0x4a', '0x94', '0x33', '0x66', '0xcc', '0x83', '0x1d', '0x3a', '0x74', '0xe8', '0xcb', '0x8d'
% };

