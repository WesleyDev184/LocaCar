-- SQLBook: Code
-- Active: 1662482481446@@127.0.0.1@3306@locacar
create table Cliente (
	cpf int not null,
	telefone varchar(12) not null,
    nome varchar(50) not null,
    primary key (cpf)
);

create table Tipo (
	nome varchar(20) not null,
    valor_diario float not null, 
    valor_semanal float not null,
    primary key (nome)
);

create table Carro (
	id_carro int auto_increment not null,
    tipo_nome varchar(20) not null,
    marca varchar(20) not null, 
    modelo varchar(20) not null, 
    ano varchar(20) not null,
    disponivel boolean not null, 
    primary key (id_carro),
    foreign key (tipo_nome) references Tipo(nome)
);

create table Aluguel (
	cpf int not null, 
    id_carro int not null, 
    data_inicio date not null,
    hora TIME,
    aluguel_ativo BOOLEAN not null,
    num_dias int not null,
    valor float not null,
    primary key (cpf, id_carro, data_inicio, hora),
    foreign key (id_carro) references Carro(id_carro),
    foreign key (cpf) references Cliente(cpf)
);

# Procedimento para a inserção de Tipos de carro
delimiter $$
create procedure insere_tipo(in nome varchar(20), in valor float) 
begin
    declare semanal float;
    set semanal = 7 * (valor - (valor * 0.20));
    insert into Tipo values(nome, valor, semanal);
end$$

# Procedimento para a inserção de carro
delimiter $$
create procedure insere_carro(in tipo varchar(20), in marca varchar(20), 
                                in modelo varchar(20), in ano varchar(5)) 
begin
    insert into Carro(tipo_nome, marca, modelo, ano, disponivel) values(tipo, marca, modelo, ano, TRUE);
end$$

# Procedimento para a inserção de Clientes
delimiter $$
create procedure insere_cliente(in cpf int, in telefone varchar(12), in nome varchar(50)) 
begin 
    insert into Cliente(cpf, telefone, nome) values(cpf, telefone, nome);
end$$

# Procedimento para a inserção do Aluguel
delimiter $$
create procedure insere_aluguel(in cpf int, in id_carro int, 
                        in data_inicio date, in num_dias int) 
begin
    declare tipo_car varchar(20);
    declare val_diario float default 0.0;
    declare val_semanal float default 0.0;
    declare valor float default 0.0;
    declare disp boolean;
    declare dias int;

    set dias = num_dias;
    set tipo_car = (select c.tipo_nome from Carro as c where c.id_carro = id_carro);
    set val_diario =  (select a.valor_diario from tipo as a where a.nome = tipo_car);
    set val_semanal = (select a.valor_semanal from tipo as a where a.nome = tipo_car);
    set disp = (select c.disponivel from Carro as c where c.id_carro = id_carro);

    if disp = TRUE then
        update Carro as c
        set c.disponivel = FALSE
        where c.id_carro = id_carro;

        while dias >= 7 do
            set dias = dias - 7;
            set valor = valor + val_semanal;
        end while;

        set valor = valor + (dias * val_diario);

        insert into Aluguel(cpf, id_carro, data_inicio, hora, num_dias, aluguel_ativo, valor) 
        values(cpf, id_carro, data_inicio, TIME(CURRENT_TIMESTAMP()), num_dias, TRUE, valor);
    end if;  
    
end$$


# trigger que atualiza os carros quando um aluguel e finalizado
delimiter $$
CREATE TRIGGER atualiza_carro_e_aluguel AFTER UPDATE ON aluguel
FOR EACH ROW
BEGIN
    UPDATE carro SET disponivel = True where id_carro = new.id_carro;
END$$

# Procedimento que atualiza o valor dos carros atrasados e a cada dia que 
# passar da devolucao adiciona mais uma diaria ao valor
delimiter $$
CREATE PROCEDURE atrasados(IN id_c int, in quant_dias int)
begin
    declare data_atual date;
    declare valor_diario float;
    set data_atual = (select curdate());
    set valor_diario = (select distinct tip.valor_diario from Carro as Car, tipo as tip
    where Car.tipo_nome = tip.nome and Car.id_carro = id_c);

    UPDATE aluguel 
    set valor = valor + ( valor_diario * quant_dias), data_inicio = data_atual, num_dias = 1 
    where id_carro = id_c;
end$$