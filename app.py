from flask import Flask, render_template, request # Classe que implementa gateway(WSGI)
from mysql.connector import errorcode
from werkzeug.utils import redirect
import mysql.connector
import datetime
import dotenv
import os

dotenv.load_dotenv(dotenv.find_dotenv())
senha = os.getenv("password")
data_base = os.getenv("database")
bd_user = os.getenv("user")

app = Flask(__name__) # Cria uma instancia do gateway

# Cria conexão com banco de dados
def get_db_con():
    try:
        conn = mysql.connector.connect(host="localhost", port=3306, user=bd_user, password=senha, database = data_base)
        print('Conexão Estabelecida')
        return conn
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            print("Usuário ou Senha inválidos!")
            return None
        if err.errno == errorcode.ER_BAD_DB_ERROR:
            print("Banco de Dados Inexistente")
            return None 

def get_carros():
    conn = get_db_con()
    if conn == None:
        return "<p>problemas com conexão</p>"
    else :
        cur = conn.cursor()

        cur.execute("""
        select id_carro, tipo_nome, marca, modelo, ano, CASE
            when disponivel = 1 then
            'Disponível'
            else
            'Alugado'
            end as disponibilidade
        from Carro;
        """)
       
        carros = cur.fetchall()
        cur.close()
    return carros

def get_aluguel():
    conn = get_db_con()
    if conn == None:
        return "<p>problemas com conexão</p>"
    else :
        cur = conn.cursor()

        cur.execute("""
        select distinct Cli.nome, Cli.cpf, Car.modelo, Car.id_carro, Al.data_inicio, DATE_ADD(Al.data_inicio, INTERVAL Al.num_dias DAY) as data_entrega, Al.valor, Al.aluguel_ativo
        from Cliente as Cli, Carro as Car, Aluguel as Al
        where Cli.cpf = Al.cpf and Car.id_carro = Al.id_carro AND Al.aluguel_ativo = 1;
        """)
       
        data = cur.fetchall()
        cur.close()
        return data
            

# Rota principal que faz a exibição das informações de aluguel e carros
@app.route('/', methods = [ 'GET' ])
def index():
    conn = get_db_con()
    if conn == None:
        return "<p>problemas com conexão</p>"
    else:
        cur = conn.cursor()
        data_atual = datetime.date.today()
        for i in get_aluguel():
            data_devolucao = i[5]
            id_c = i[3]
            quantidade_dias = abs((data_atual - data_devolucao).days)
            if data_devolucao <= data_atual:
                cur.callproc('atrasados', [id_c, quantidade_dias])
                conn.commit()
        cur.close()
    
    return render_template('index.html', aluguel = get_aluguel(), dados = get_carros())

# Rota para cadastrar novos clientes
@app.route('/cad_cli')
def get_form_cadastro_cli():
    return render_template('Cad_cliente.html')

@app.route('/cadastrar_cliente', methods = [ 'POST' ])
def cadastrar_cliente():
    conn = get_db_con()
    if conn == None:
        return "<p>problemas com conexão</p>"
    else :
        cur = conn.cursor()
        
        cpf = request.form['cpf']
        tel = request.form['telefone']
        nome = request.form['nome']
        
        cur.callproc('insere_cliente', [cpf, tel, nome])
        
        conn.commit()
        
        cur.close()
        
        return redirect('http://127.0.0.1:5000')

# Rota para cadastrar novos carros
@app.route('/cad_car')
def get_form_cadastro_prod():
    return render_template('Cad_car.html')
        
@app.route('/cadastrar_carro', methods = [ 'POST' ])
def cadastrar_carro():
    conn = get_db_con()
    if conn == None:
        return "<p> problemas com conexão</p>"
    else :
        cur = conn.cursor()
        
        tipo_nome = request.form['tipo_nome']
        marca = request.form['marca']
        modelo = request.form['modelo']
        ano = request.form['ano']
  
        cur.callproc('insere_carro', [tipo_nome, marca, modelo, ano])
        cur.close()
        conn.commit()
        
        return redirect('http://127.0.0.1:5000')

@app.route('/alugueis_encerrados')
def get_alugueis_encerrados():
    conn = get_db_con()
    if conn == None:
        return "<p>problemas com conexão</p>"
    else :
        cur = conn.cursor()

        cur.execute("""
        select distinct Cli.nome, Cli.cpf, Car.modelo, Car.id_carro, Al.data_inicio, DATE_ADD(Al.data_inicio, INTERVAL Al.num_dias DAY) as data_entrega, Al.valor
        from Cliente as Cli, Carro as Car, Aluguel as Al
        where Cli.cpf = Al.cpf and Car.id_carro = Al.id_carro AND Al.aluguel_ativo = 0;
        """)
       
        data = cur.fetchall()
        cur.close()
    return render_template('alugueis_encerrados.html', aluguel_encerrados = data)
        

# Endpoint que para o cadastro dos alugueis de veículos 
@app.route('/cadastrar_aluguel', methods = [ 'POST' ])
def cadastrar_aluguel():
    conn = get_db_con()
    if conn == None:
        return "<p> problemas com conexão</p>"
    else :
        cur = conn.cursor()
        
        id_car = request.form['id_carro']
        id_cli = request.form['id_cliente']
        data = datetime.date.today()
        num_dias = request.form['num_dias']
        
        cur.callproc('insere_aluguel', [id_cli, id_car, data, num_dias])
        conn.commit()
        
        cur.close()

        return redirect('http://127.0.0.1:5000')

# Endpoint que atualiza os alugueis finalizados os colocando na tabela aluguel_encerrado por meio de trigger
@app.route('/update/<int:cpf>/<int:id_carro>/<string:data>/<int:ativo>', methods= ['POST', 'GET'])
def update(cpf, id_carro, data, ativo):
    conn = get_db_con()
    if conn == None:
        return "<p> problemas com conexão</p>"
    else :
        cur = conn.cursor()
        
        cur.execute('update Aluguel set aluguel_ativo = false WHERE cpf = %s and id_carro = %s and data_inicio = %s and aluguel_ativo = %s', (cpf, id_carro, data, ativo,))

        conn.commit()
        cur.close()
        return redirect('http://127.0.0.1:5000')


if __name__ == '__main__':
    app.run(debug=True)
