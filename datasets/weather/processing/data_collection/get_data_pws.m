function get_data_pws(pws_str)

key_set = cell(1,46);

key_set{1} = 'ae94df645f2be4cb';
key_set{2} = '9db620c0f3b89dca';
key_set{3} = '86dd35b6013393a2';
key_set{4} = '26f631a91118ae33';
key_set{5} = '6ee0f398f52f3380';
key_set{6} = 'a55d0dde66897118';
key_set{7} = 'e2be1a722d1456a8';
key_set{8} = '3332fa7e01c27ce4';
key_set{9} = '1d72859694de8203';
key_set{10} = 'ff3f04fc1e48e84a';
key_set{11} = '7c24cdf6576c7e97';
key_set{12} = '4431186dcf66976a';
key_set{13} = '086267be1ab7bea7';
key_set{14} = 'cef5c1b80730570c';
key_set{15} = '6d5c407fbe58632e';
key_set{16} = '15fd83526b1c5397';
key_set{17} = '8a9f9b9a560ffab7';
key_set{18} = 'a3fb72452c1bb5f2';
key_set{19} = 'efb48b6bab14f3a8';
key_set{20} = '47c3136003b62644';
key_set{21} = '6be3f5402dca4df7';
key_set{22} = '2515284a39f75d68';
key_set{23} = 'a0e80c483bebf405';
key_set{24} = '696de37e5215cf24';
key_set{25} = '64ccfe78383da1b6';
key_set{26} = 'd23ce36e55d3b160';
key_set{27} = 'b59a914030878918';
key_set{28} = 'a375415ac807e8c8';
key_set{29} = '0b45ae8d770e4502';
key_set{30} = 'fd615a094e3618dd';
key_set{31} = 'fb76e5b56834c58c';
key_set{32} = '5d2b4895f7eb4662';
key_set{33} = 'db89c3e4934c9229';
key_set{34} = 'd57fb874de1c93eb';
key_set{35} = '78eccb5161cf8a1d';
key_set{36} = '21dfed580ba73a17';
key_set{37} = '7660739d6f9dd236';
key_set{38} = '88347c59d40e4ee9';
key_set{39} = 'a60130e36d7f2a65';
key_set{40} = 'ab0fbabff618532b';
key_set{41} = '9df507cdf9a8296f';
key_set{42} = '3330ff7d15f63923';
key_set{43} = '6442be3a849efe51';
key_set{44} = '1fccab8237babeec';
key_set{45} = 'd4bc262b0a8f3e1a';
key_set{46} = '09df3fb2451f1b7d';

get_data_fun(pws_str, key_set, '2015', 1, 12);
get_data_fun(pws_str, key_set, '2016', 1, 8);

% n_obsv1 = get_data_fun_check(pws_str, key_set, '2015', 1, 12);
% n_obsv2 = get_data_fun_check(pws_str, key_set, '2016', 1, 8);
% 
% n_obsv1
% n_obsv2
%get_data_fun(pws_str, key_set, '2015', 1, 3);