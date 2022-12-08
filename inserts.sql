-- Active: 1669136213736@@127.0.0.1@3306@locacar
call insere_tipo('COMPACTO', 40);
call insere_tipo('CAMINHAO', 250);
call insere_tipo('GRANDE', 73);
call insere_tipo('MEDIO', 52);
call insere_tipo('SUV', 80);
call insere_tipo('VAN', 101);

call insere_cliente(18444,66999785567,'wesley');
call insere_cliente(23145,66999785567,'juliana');
call insere_cliente(55555,66999785567,'linder');
call insere_cliente(56687,66999785567,'Paulo');
call insere_cliente(66666,66999785567,'Pedro');
call insere_cliente(77777,66999785567,'carlos');
call insere_cliente(84652,66999785567,'John');
call insere_cliente(84875,66999785567,'Claudinet');
call insere_cliente(88888,66999785567,'Maria');
call insere_cliente(99999,66999785567,'Beth');


call insere_carro('COMPACTO', 'Fiat', 'Mobi', 2020);
call insere_carro('COMPACTO', 'Renault', 'Kwid', 2018);
call insere_carro('COMPACTO', 'Volkswaagen', 'UP', 2019);
call insere_carro('COMPACTO', 'Fiat', 'uno', 2015);
call insere_carro('CAMINHAO', 'Volvo', 'FH-540', 2015);
call insere_carro('CAMINHAO', 'Volkswaagen', 'Delivery-11.280', 2020);
call insere_carro('CAMINHAO', 'Scania', 'R460', 2020);
call insere_carro('CAMINHAO', 'Volvo', 'FH-460', 2017);
call insere_carro('GRANDE', 'Hyundai', 'Tucson', 2020);
call insere_carro('GRANDE', 'Chery', 'Tiggor', 2019);
call insere_carro('GRANDE', 'Chevrolet', 'Spin', 2016);
call insere_carro('MEDIO', 'Volkswagen', 'Polo', 2015);
call insere_carro('MEDIO', 'Fiat', 'Argo', 2020);
call insere_carro('MEDIO', 'Hyundai', 'HB20s', 2017);
call insere_carro('SUV', 'Fiat', 'Pulse', 2021);
call insere_carro('SUV', 'Peugeot', '2008', 2021);
call insere_carro('SUV', 'Jac', 'T40 Plus', 2020);
call insere_carro('SUV', 'Renault', 'Duster', 2019);
call insere_carro('VAN', 'Fiat', 'Ducato', 2020);
call insere_carro('VAN', 'Mercedes-Benz', 'Sprinter-313', 2020);
call insere_carro('VAN', 'Pegeot', 'Boxer', 2020);